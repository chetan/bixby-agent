
jQuery ->

  Bixby.app.add_state(
    class MonViewHostState extends Stark.State
      name: "mon_view_host" #  canonical name used for state transitions
                            #  e.g., it is referred to in events hash of other states

      url:  "monitoring/hosts/:host_id" #  match() pattern [optional]

      views:      [ Bixby.view.PageLayout, Bixby.view.monitoring.Layout ]
      no_redraw:  [ Bixby.view.PageLayout, Bixby.view.monitoring.Layout ]
      models:     { host: Bixby.model.Host, resources: Bixby.model.ResourceList }

      events: {
        mon_hosts_resources_new: { models: [ Bixby.model.Host ] }
      }

      create_url: ->
        @url.replace /:host_id/, @host.id

      load_data: ->
        needed = []
        if ! @host?
          @host = new Bixby.model.Host({ id: @params.host_id })
          needed.push @host

        if ! @resources?
          host_id = (@params? && @params.host_id) || @host.id
          @resources = new Bixby.model.ResourceList(host_id)
          needed.push @resources

        return needed

      activate: ->
        @app.trigger("nav:select_tab", "monitoring")
  )

  # Bixby.router.route "monitoring/hosts/:host_id/resources/new", "monitoring_hosts_resources_new", (host_id) ->
  #   console.log("monitoring_hosts_resources_new() route called")

