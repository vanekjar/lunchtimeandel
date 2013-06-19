
i18n = require 'i18n'
moment = require 'moment'

module.exports = (Schema) ->
    Meal = require('./meal')(Schema)

    Restaurant = new Schema
        name: String
        urls:
            homepage: String
            lunchmenu: String
        lastUpdate: Date
        meals: [Meal]
        phoneNumber: String
        address:
            street: String
            city: String
            zip: Number
            map:
                lat: Number
                lng: Number

    Restaurant.methods.getPrintalbeLastUpdate = () ->
        moment.lang i18n.getLocale()
        moment(@lastUpdate).format __ 'MMMM D, H:mm A'

    Restaurant.methods.getRandomMeal = () ->
        meals = []
        for meal in @meals
            meals.push meal if meal.price > 50

        rand = Math.floor(Math.random() * meals.length)
        meals[rand]

    Restaurant.pre 'save', (next) ->
        mealNames = []
        meals = []
        for meal in @meals
            if meal.name not in mealNames
                meals.push meal
            mealNames.push meal.name
        @meals = meals
        next()

    Restaurant.statics.random = (callback) ->
        @find {meals: {$not: {$size: 0}}}, (err, restaurants) ->
            if err
                return callback err
            rand = Math.floor(Math.random() * restaurants.length)
            callback err, restaurants[rand]

    Restaurant
