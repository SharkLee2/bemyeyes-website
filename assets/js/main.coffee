getStats = () ->
	url = "https://apiv2.bemyeyes.org/stats/community?callback=?"
	xhr = $.getJSON url, () ->
		console.log "API Stat response"

	xhr.done (json) ->
		console.log json
		applyStats json.blind, json.helpers, json.no_helped
		# delay 30000, ->
		# 	getStats()

	xhr.fail () ->
		console.log "Failed to get api stats"

applyStats = (blind, helpers, helped) ->
	offset = 400
	countTotStat "stats_helpers", helpers
	delay offset, ->
		countTotStat "stats_blind", blind
		delay offset, ->
			countTotStat "stats_helped", helped

countTotStat = (elem, stat) ->
	start = parseInt($("#" + elem).html().replace(",", ""))
	anim = new countUp(elem, start, stat, 0, 2.0)
	anim.start()

delay = (ms, func) ->
	setTimeout func, ms

animateFeatures = ->
	$(".features .feature").each ->
		$obj = $(this)

		return if $obj.hasClass 'animated'

		windowHeight = $(window).height()
		windowOffset = $(window).scrollTop()
		offset = $obj.offset().top

		if offset < (windowOffset + windowHeight)
			scrolled = Math.round(((windowOffset + windowHeight - offset) / windowHeight ) * 100)
			if scrolled > 10
				$obj.addClass 'animated'
				$obj.transition {scale: 1.2}, 400
				$obj.transition {scale: 1.0}, 200

userAgent = navigator.userAgent
isiPhone = userAgent.match(/iPhone/i) != null ? true : false
isiPad = userAgent.match(/iPad/i) != null ? true : false
isSafari = userAgent.match(/Safari/i) != null ? true : false
isiOS = isiPhone || isiPad

desktopPlayer = '<iframe id="headervid" src="//player.vimeo.com/video/113872517?api=1&amp;player_id=headervid&amp;title=0&amp;byline=0&amp;portrait=0" width="1020" height="573" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>'
iPhonePlayer = '<video id="headervid" src="http://static.robocatapps.com/bemyeyes/bemyeyes-mobile.mov" controls="controls" webkitAllowFullScreen mozallowfullscreen allowFullScreen autoplay preload></video>'

preparePlayer = ->
	player = desktopPlayer
	player = iPhonePlayer if isiOS

	$('.video-wrapper').html player

hidePlayer = ->
	$('.menu-container').css('opacity', 1)
	$('.menu-container').css('pointer-events', 'auto')
	$('.menu').show()
	$(".video-curtain").fadeOut()
	$(".video-wrapper").fadeOut()

showPlayer = ->
	$('.menu-container').css('opacity', 0)
	$('.menu-container').css('pointer-events', 'none')
	$('.menu').hide()
	$(".video-curtain").fadeIn()
	$(".video-wrapper").fadeIn()

startVideo = ->
	showPlayer()
	if !isiOS
		Froogaloop($("#headervid")[0]).addEvent 'ready', vimeoReady
	else
		ele = document.getElementById("headervid")
		ele.addEventListener 'pause', vimeoPaused
		ele.addEventListener 'ended', vimeoPaused
		ele.play()

vimeoReady = (pid) ->
	if !isiOS
		fp = Froogaloop(pid)
		fp.addEvent 'pause', vimeoPaused
		fp.addEvent 'finish', vimeoFinished
		fp.api 'play'

vimeoPaused = (pid) ->
	if isiOS
		delay 100, ->
			hidePlayer()

vimeoFinished = (pid) ->
	delay 2000, ->
		hidePlayer()

$(window).scroll ->
	return if isiOS
	$this = $(this)
	$header = $(".container")
	if $this.scrollTop() > 1
		$header.addClass "sticky"
	else
		$header.removeClass "sticky"

	animateFeatures()

$('body').bind 'touchmove', (e) ->
	animateFeatures()

$(document).ready ->
	getStats()
	preparePlayer()

	$(".header").click (e) ->
		startVideo()

	$("#fb_share").click (e) ->
		FB.ui {method: "share", href: "http://bemyeyes.org/"}