
"use strict"

window.Stark or= {}

class Stark.View extends Backbone.View

  # mixin logger
  _.extend @.prototype, Stark.Logger.prototype
  logger: "view"

  # [internal] Reference to the Stark::App instance
  app: null

  # [internal] Reference to the current Stark::State instance
  state: null

  # File name of the template rendered by this view
  template: null

  # Selector for element into which this view will be rendered
  # (usually a div or span). Can be a string (CSS selector) or
  # a function.
  selector: null

  # Hash of links to create and bind.
  # The keys are selectors and the value is an array. The first element of the
  # array is the state name which will be activated when the link is clicked,
  # and the second value is a hash of data models to pass into the new state.
  #
  # Instead of a hash, a function may be passed which would be called onClick.
  # The result of this function should be a hash of models.
  #
  # Examples:
  #
  #   Simple links:
  #
  #     links: {
  #       "a.brand": [ "inventory" ]
  #       ".tab.monitoring a": [ "monitoring", { foo: "bar" } ]
  #     }
  #
  #   Using a function:
  #
  #     links: {
  #       ".monitoring_host_link": [ "mon_view_host", (el) ->
  #         return { host: @hosts.get( $(el).attr("host_id") ) }
  #       ]
  #     }
  #
  links: null

  # List of events to subscribe to at the @app level
  app_events: null

  # List of sub-views
  views: []

  initialize: ->
    _.bindAll @

  # Lookup @template in the global JST hash
  jst: ->
    JST[ @app.template_root + @template ]

  # Create a Template object for the configured @template
  #
  # In practice, this can be overidden to use your preferred
  # template library, as long as it responds to #render(context),
  # where context is a reference to the view itself.
  create_template: ->
    new Template(@jst())

  # Default implementation of Backbone.View's render() method. Simply renders
  # the @template into the element defined by @selector.
  #
  # Custom rendering should usually call super() before any additional
  # rendering.
  render: ->

    @log "rendering view", @
    @_template = @create_template()

    # use an optional [dynamic] selector
    el = null
    if @selector?
      if _.isFunction(@selector)
        el = @selector()
      else
        el = el
    else
      el = @el

    @setElement(el)
    @$el.html(@_template.render(@))

    @attach_link_events()

    return @

  # Process @links hash and attach events
  attach_link_events: ->

    return if not @links?

    link_events = @events || {}

    _.each @links, (link, sel) ->

      _.each $(sel), (el) ->

        state = link[0]
        data = null
        if link.length > 1
          data = link[1]

        # setup delegate event
        link_events["click " + sel] = (e) ->
          if e.altKey || e.ctrlKey || e.metaKey || e.shiftKey
            return # let click go through (new tab, etc)

          # stop normal click event (navigate to href)
          # so we can instead do some internal routing (transition)
          e.preventDefault();
          @transition(state, @get_link_data(data, e.target))


        return if not @app.states[state]?

        # create url for the state with the required data from this view
        s = new @app.states[state]()
        _.extend s, @get_link_data(data, el)

        url = s.create_url()
        url = "/" + url if url.charAt(0) != '/'

        $(el).attr("href", url)

      , @ # each sel
    , @ # each link

    # bind events
    @delegateEvents(link_events)

  # Helper for resolving data to a set of actual values
  #
  # @param [Object] data    Data hash
  # @param [Element] el     Element which data should be generated for (in the function case)
  get_link_data: (data, el) ->
    ret = {}

    if not data?
      return ret

    if _.isArray(data)
      _.each data, (key) ->
        ret[key] = @[key]
      , @

    else if _.isFunction(data)
      data = data.call(@, el)
      _.each data, (val, key) ->
        ret[key] = val

    return ret




  # Proxy for Stark.state#transition
  transition: (state_name, state_data) ->
    @state.transition(state_name, state_data)

  # Subscribe to all @app level events as defined in the @app_events var
  bind_app_events: ->
    _.each @app_events, (cb, key) ->
      @app.subscribe(key, cb, @)
    , @

  # Unsubscribe all @app level events (see #bind_app_events)
  unbind_app_events: ->
    _.each @app_events, (cb, key) ->
      @app.unsubscribe(key, cb, @)
    , @

  # Cleanup any resources used by the view. Should remove all views and unbind any events
  dispose: ->
    @$el.html("")
    @unbind_app_events()
    @undelegateEvents()
    for v in @views
      v.dispose()
