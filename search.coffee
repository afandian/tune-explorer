###
Folk Tune Finder tune explorer!

The bit that just does searches and displays them and stuff.

Copyright Joe Wass 2011 - 2013
joe@afandian.com
###

class Searcher
    constructor : (@resultsElement, @apiUrl) ->
        jQuery("body").bind("searchPathChanged", @search)

    search : (event, path) =>
        query = @queryString(path)
        args =
            url: query
            dataType: 'jsonp'
            success: (data) ->
                console.log(data)

        jQuery.ajax(args, (data) ->
            console.log(data)
        )

    queryString : (path) =>

        params =
            melody: path.join(",")

        return @apiUrl + "?" + jQuery.param(params) #+ "?callback=callback"



jQuery ->
    searchResultsElement = document.getElementById("results")
    API_URL = "http://api-cache.folktunefinder.com/search/"
    API_URL = "http://folktunefinder.com:8080/search/"

    searcher = Searcher(searchResultsElement, API_URL)
