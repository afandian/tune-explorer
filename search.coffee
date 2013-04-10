###
Folk Tune Finder tune explorer!

The bit that just does searches and displays them and stuff.

Copyright Joe Wass 2011 - 2013
joe@afandian.com
###

class Searcher
    constructor : (@resultsElement, @apiUrl, @imageUrl, @tuneUrl) ->
        jQuery("body").bind("searchPathChanged", @search)

    search : (event, path) =>
        query = @queryString(path)
        args =
            url: query
            dataType: 'jsonp'
            success: (data) =>
                $("#number").text(data.TotalFound)

                results = $("#result-list")
                results.empty()
                for result in data.Results
                    docId = result.DocumentId
                    starts = result.Starts
                    ends = result.Ends
                    selectionRange = [starts..ends].join(":")
                    title = result.Title.join(" / ")

                    imageUrl = @imageUrl + docId + "/"
                    urlWithSelection = imageUrl + selectionRange + "/"

                    tuneUrl = @tuneUrl + docId + "/"

                    li = $("<li></li>")
                    li.append($("<a>", href: tuneUrl).text(title).append($("<img>",
                        src : urlWithSelection
                        alt : title
                        class : "selection",
                        )))

                    results.append(li)


        jQuery.ajax(args)

    queryString : (path) =>

        params =
            melody: path.join(",")

        return @apiUrl + "?" + jQuery.param(params) #+ "?callback=callback"



jQuery ->
    searchResultsElement = jQuery("#results")
    API_URL = "http://api-cache.folktunefinder.com/search/"
    INCIPIT_IMAGE_BASE = "http://cache.folktunefinder.com/typeset/dots/incipit/"
    TUNE_URL = "http://folktunefinder.com/tune/"

    searcher = Searcher(searchResultsElement, API_URL, INCIPIT_IMAGE_BASE, TUNE_URL)
