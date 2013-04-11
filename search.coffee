###
Folk Tune Finder tune explorer!

The bit that just does searches and displays them and stuff.

Copyright Joe Wass 2011 - 2013
joe@afandian.com
###

class Searcher
    constructor : (@resultsElement, @apiUrl, @imageUrl, @tuneUrl) ->
        jQuery("body").bind("searchPathChanged", @search)
        jQuery("#next").bind("click", @goNextPage)
        jQuery("#prev").bind("click", @goPrevPage)

        @currentPage = 1
        @nextPage = -1
        @prevPage = -1
        @numPages = -1

    # Go to next page or ignore.
    goNextPage : () =>
        if @nextPage != -1
            @currentPage = @nextPage
            @search()

    # Go to next page or ignore.
    goPrevPage : () =>
        if @prevPage != -1
            @currentPage = @prevPage
            @search()

    search : (event, path) =>
        # If this is re-raised without a new path, use the previous one.
        if path == undefined
            path = @path
        else
            @path = path

            # Start at first page for a new search.
            @currentPage = 1

        # Update the URL so we can click back on links.
        # No pushstate stuff. At least not yet.

        query = "#" + path.join(":")
        history.replaceState(null, null, query);

        query = @queryString(path)
        args =
            url: query
            dataType: 'jsonp'
            success: (data) =>
                @prevPage = data.PrevPage
                @nextPage = data.NextPage
                @numPages = data.NumPages

                if @nextPage > 0
                    jQuery("#next").show()
                else
                    jQuery("#next").hide()

                if @prevPage > 0
                    jQuery("#prev").show()
                else
                    jQuery("#prev").hide()


                tuneWord = "tune" + if data.TotalFound == 1 then "" else "s"

                $("#summary").text("Found " + data.TotalFound + " " + tuneWord + ". Page " + @currentPage + " of " + @numPages + ".")

                results = $("#result-list")
                results.empty()
                for result in data.Results
                    docId = result.DocumentId
                    starts = result.Starts
                    ends = result.Ends

                    title = result.Title.join(" / ")
                    if title.length == 0
                        title = "(no title)"
                    imageUrl = @imageUrl + docId + "/"
                    if starts != -1 and ends != -1
                        selectionRange = [starts..ends].join(":")
                        urlWithSelection = imageUrl + selectionRange + "/"
                    else
                        urlWithSelection = imageUrl


                    tuneUrl = @tuneUrl + docId + "/"

                    li = $("<li></li>")
                    li.append($("<a>", href: tuneUrl).text(title).append($("<img>",
                        src : urlWithSelection
                        alt : title
                        class : "selection",
                        )))

                    results.append(li)

                $("html, body").animate({ scrollTop: 0 }, "slow");


        jQuery.ajax(args)

    queryString : (path) =>
        # Take first page or the most recently requested one.
        page = if @currentPage != -1 then @currentPage else 1

        params =
            melody: path.join(",")
            page: page

        return @apiUrl + "?" + jQuery.param(params) #+ "?callback=callback"



jQuery ->
    searchResultsElement = jQuery("#results")
    API_URL = "http://api-cache.folktunefinder.com/search/"
    INCIPIT_IMAGE_BASE = "http://cache.folktunefinder.com/typeset/dots/incipit/"
    TUNE_URL = "http://folktunefinder.com/tune/"

    searcher = Searcher(searchResultsElement, API_URL, INCIPIT_IMAGE_BASE, TUNE_URL)
