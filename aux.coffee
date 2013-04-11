jQuery ->
    jQuery("#help").click((event)->
        jQuery(this).fadeOut(event)
        )

    # Keep results pane in place.
    jQuery(window).scroll(() ->
        jQuery('#results').css
            left: $(this).scrollLeft())

    window.setTimeout((()->jQuery("#help").fadeOut()), 15000)
