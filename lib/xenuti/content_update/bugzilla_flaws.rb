# Copyright (C) 2014 Jan Rusnacko
#
# This copyrighted material is made available to anyone wishing to use,
# modify, copy, or redistribute it subject to the terms and conditions of the
# MIT license.

require 'xmlrpc/client'
require 'pstore'
require 'json'

class Xenuti::ContentUpdate::BugzillaFlaws
  THREAD_NUM = 16 # sweet spot
  STORE_THREAD_TIMEOUT = 3
  REDHAT_BUGZILLA = 'bugzilla.redhat.com'

  class << self
    def update(config, report)
      client = XMLRPC::Client.new('bugzilla.redhat.com', '/xmlrpc.cgi',
                                  nil, nil, nil, nil, nil, true, 60)
      FileUtils.mkdir_p config[:general][:workdir]
      store = get_store(config)

      download(flaws_to_download(store, client), store)

      flaws_json_path = File.join(config[:general][:workdir], 'flaws.json')
      File.open(flaws_json_path, 'w+') do |fd|
        fd.write JSON.dump store.transaction { store[:flaws] }.values
      end

      config[:content_update][:source] = flaws_json_path
    end

    # Convert all bugzilla fields containing XMLRPC::DateTime to Time
    def convert_xmlrpc_times(bug)
      bug.each do |field, val|
        bug[field] = val.to_time if val.is_a? XMLRPC::DateTime

        # Convert all comment fields containing XMLRPC::DateTime to Time
        bug[field].each do |comment|
          comment.each do |cfield, cval|
            comment[cfield] = cval.to_time if cval.is_a? XMLRPC::DateTime
          end
        end if field == 'comments'
      end
      bug
    end

    def get_store(config)
      store_path = File.join(config[:general][:workdir], 'cached')
      store = PStore.new(store_path, thread_safe = true)
      if(store.transaction { store[:flaws] }.nil?)
        store.transaction { store[:flaws] = {} }
      end
      store
    end

    def download(ids_to_download, store)
      downloaded_count = 0
      mutex = Mutex.new
      to_save = []


      # Saving to PStore is slow if it`s big - this is a worker thread that will
      # save bugs from to_save queue to PStore in chunks.
      store_thread = Thread.new do

        while true
          sleep STORE_THREAD_TIMEOUT
          mutex.synchronize do
            store.transaction do
              to_save.each do |bug|
                store[:flaws][bug['id']] = bug
              end
            end
            $log.debug "Saved #{to_save.collect { |b| b['id'] }}"
            downloaded_count += to_save.size
            $log.info "Downloaded #{downloaded_count} bugs"
            to_save = []
          end
        end
      end

      $log.info "Downloading #{ids_to_download.size} flaws ..."
      THREAD_NUM.times.map {
        Thread.new do
          # each thread has it`s own connection
          client = XMLRPC::Client.new('bugzilla.redhat.com', '/xmlrpc.cgi',
                                  nil, nil, nil, nil, nil, true, 60)
          while id = mutex.synchronize { ids_to_download.shift }
            bug = client.call('Bug.search', {
              :id             => id,
              :component      => 'vulnerability',
              :include_fields => ['alias', 'blocks', 'comments', 'creation_time',
              'creator', 'depends_on', 'id', 'keywords', 'last_change_time',
              'priority', 'resolution', 'severity', 'status', 'summary',
              'whiteboard'],
              :product        => 'Security Response'
            })['bugs'].first
            convert_xmlrpc_times(bug)

            mutex.synchronize { to_save << bug }

            # store.transaction { store[:flaws][bug['id']] = bug }
            $log.debug "Downloaded bugzilla #{bug['id']}"
          end
        end
      }.each(&:join)

      5.times do
        if(to_save.empty?)
          store_thread.kill
          break
        end
        sleep STORE_THREAD_TIMEOUT
      end

      $log.info "... done."
    end

    def current_flaws(xmlrpc_client)
      if @current.nil? 
        @current = xmlrpc_client.call('Bug.search', {
          component:      'vulnerability',
          product:        'Security Response',
          include_fields: ['id','last_change_time']})['bugs']
        @current.each do |bug|
          convert_xmlrpc_times(bug)
        end
      end
      @current
    end

    def cached_flaws(store)
      @cached ||= store.transaction { store.fetch(:flaws, {}) }
    end

    # Returns Array of vulnerability IDs that are either missing or outdated
    def flaws_to_download(store, xmlrpc_client)
      $log.info "Determining flaws to be downloaded from bugzilla ..."
      to_download = []
      cached = cached_flaws(store)
      current_flaws(xmlrpc_client).each do |current|
        if(cached[current['id']].nil? ||
          current['last_change_time'] > cached[current['id']]['last_change_time'])
          to_download << current['id']
        end
      end
      $log.info "... done."
      to_download
    end
  end
end