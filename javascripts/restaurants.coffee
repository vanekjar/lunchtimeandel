
goog.provide 'lta.Restaurants'

goog.require 'goog.dom'
goog.require 'goog.History'
goog.require 'lta.Restaurant'
goog.require 'lta.ChoiceHelp'


class lta.Restaurants
    ###*
    @type {Array}
    @private
    ###
    restaurants_: []

    ###*
    @type {goog.History}
    @private
    ###
    history_: null

    ###*
    @type {google.maps.Map}
    @private
    ###
    googleMap_: null

    ###*
    @constructor
    ###
    constructor: (mapOptions) ->
        @createGoogleMap_ mapOptions
        @constructHistory_()

    createGoogleMap_: (mapOptions) ->
        # Mobile is without map. Better for time execution and data needed to be downloaded.
        window.console.log 'ismob', goog.userAgent.MOBILE
        if goog.userAgent.MOBILE
            return
        elm = goog.dom.getElement 'restaurants_map'
        window.console.log 'register map', elm, mapOptions
        @googleMap_ = new google.maps.Map elm, mapOptions

    ###*
    @private
    ###
    constructHistory_: () ->
        that = @
        @history_ = new goog.History()
        @history_.setEnabled true
        goog.events.listen @history_, goog.history.EventType.NAVIGATE, (e) -> that.historyNavigate_ e

    ###*
    @private
    ###
    historyNavigate_: (e) ->
        for restaurant in @restaurants_
            if e.token is restaurant.getId() then restaurant.mark() else restaurant.unmark()

    ###*
    @expose
    ###
    load: () ->
        that = @
        goog.net.XhrIo.send '/api/listall', (e) ->
            container = goog.dom.getElement 'restaurants'
            container.innerHTML = ''

            res = e.target.getResponseJson()
            for restaurant in res
                restaurant = new lta.Restaurant restaurant, that.history_
                restaurant.appendToDocument()
                restaurant.registerMapMarker that.googleMap_ if that.googleMap_
                that.restaurants_.push restaurant

            for restaurant in that.restaurants_
                if that.history_.getToken() is restaurant.getId()
                    restaurant.scrollTo()
                    restaurant.mark()
                    break

    ###*
    @param {string} query
    ###
    search: (query) ->
        for restaurant in @restaurants_
            restaurant.search query


window['lta'] = lta
lta['Restaurants'] = lta.Restaurants
