# Init multitouch event handling with Hammer 2
# --------------------------------------------
HammerEvents =
	Tap: "tap"
	DoubleTap: "doubletap"
	Hold: "hold"
	Touch: "touch"
	Release: "release"
	Gesture: "gesture"
	Swipe: "swipe"
	SwipeUp: "swipeup"
	SwipeDown: "swipedown"
	SwipeLeft: "swipeleft"
	SwipeRight: "swiperight"
	Transform: "transform"
	TransformStart: "transformstart"
	TransformEnd: "transformend"
	Rotate: "rotate"
	Pinch: "pinch"
	PinchIn: "pinchin"
	PinchOut: "pinchout"
	Drag: "drag"
	DragStart: "dragstart"
	DragEnd: "dragend"

window.Events = _.extend Events, HammerEvents

class HammerLayer extends Framer.Layer
	on: (eventName, f) ->
		if eventName in _.values(HammerEvents)
			@ignoreEvents = false
			hammer = Hammer(@_element).on eventName, f
		else
			super eventName, f

window.Layer = HammerLayer

# Enables a fake-Multitouch by holding the "Shift"-key
Hammer.plugins.fakeMultitouch()




# Variables
# ---------

cols = 4
rows = 20
if Utils.isMobile()
	dpiScale = 1
else
	dpiScale = 0.5
cardWidth = 300 * dpiScale
cardHeight = 200 * dpiScale
cardSpacing = (Screen.width - cols * cardWidth) // 5
selectedWidth = 700 * dpiScale
selectedHeight = 600 * dpiScale
selectedX = (Screen.width - (cardSpacing + 2 * selectedWidth)) // 2
selectedY = cardSpacing
poiWidth = 60 * dpiScale
poiHeight = 60 * dpiScale
navigationOriginalY = Screen.height // 3
navigationY = cardSpacing // 4

Framer.Device.fullScreen = true
Framer.Defaults.Animation = {
    curve: "cubic-bezier"
    time: 0.22
}

bg = new BackgroundLayer
	backgroundColor: "#f5f5f5"

selectedCards = []
pois = []




# Setup layers
# ------------


# Explore
Explore = new Layer
	width: Screen.width
	height: Screen.height
	backgroundColor: "transparent"

# Create main layers to hold related card grids
relatedCardsGrid = new Layer
	width: Screen.width
	height: Screen.height
	backgroundColor: "transparent"
	superLayer: Explore
relatedCardsGrid.scroll = true

# Create map container
map = new Layer
	width: Screen.width
	height: selectedHeight + 2 * cardSpacing
	x: 0
	y: 0
	backgroundColor: "#F2EEE7"
	scale: 1.2
	opacity: 0
	superLayer: Explore

map.visible = false

mapContent = new Layer
	width: 4000
	height: 4000
	superLayer: map
	backgroundColor: "transparent"
mapContent.draggable.enabled = true

# Navigation
Navigation = new Layer
	width: 1200
	height: 100
	y: Screen.height // 3
	backgroundColor: "transparent"
	borderRadius: 10
Navigation.shadowY = 10
Navigation.shadowBlur = 20
Navigation.shadowColor = "rgba(0,0,0,0.3)"
Navigation.centerX()

navbg = new Layer
	width: 1200
	height: 100
	backgroundColor: "white"
	borderRadius: 10
	superLayer: Navigation

searchForm = new Layer
	width: 800
	height: 500
	x: 20
	y: 10
	backgroundColor: "transparent"
	superLayer: Navigation

searchFormFrom = new Layer
	width: 800
	height: 80
	backgroundColor: "#eee"
	superLayer: searchForm

searchFormTo = new Layer
	width: 800
	height: 80
	y: 100
	backgroundColor: "#eee"
	superLayer: searchForm

searchFormOutDate = new Layer
	width: 390
	height: 80
	y: 200
	backgroundColor: "#eee"
	superLayer: searchForm

searchFormInDate = new Layer
	width: 390
	height: 80
	x: 410
	y: 200
	backgroundColor: "#eee"
	superLayer: searchForm

searchFormFlexible = new Layer
	width: 80
	height: 80
	y: 300
	backgroundColor: "#eee"
	superLayer: searchForm

searchFormPassengers = new Layer
	width: 390
	height: 80
	y: 400
	backgroundColor: "#eee"
	superLayer: searchForm

searchButton = new Layer
	width: 200
	height: 80
	x: 980
	y: 10
	backgroundColor: "#09f"
	borderRadius: 10
	superLayer: Navigation

backToSearchButton = new Layer
	width: 200
	height: 50
	x: 20
	y: 35
	backgroundColor: "transparent"
	superLayer: Navigation

navbarTitle = new Layer
	width: 200
	height: 50
	x: 500
	y: 35
	backgroundColor: "transparent"
	superLayer: Navigation

searchButton.html = "<div style='width: 200px; text-align: center; color: #fff; font-size: 36px;'>Search</div>"
backToSearchButton.html = "<span style='color: #06f; font-size: 36px;'>&lsaquo; Search</span>"

searchButton.on Events.Click, ->
	goto("dayview")
backToSearchButton.on Events.Click, ->
	goto("home")
searchForm.on Events.Click, ->
	goto("home-search")




# Navigation
# ------


goto = (target) ->
	switch target
		when "home"
			makeInspirationLayer()
			Explore.animate
				properties:
					y: 0
					blur: 0
					opacity: 1
			navbar("home")
			Navigation.animate
				properties: {y: navigationOriginalY}

		when "home-search"
			navbar("home-search")
			Navigation.animate
				properties: {y: navigationY}

		when "dayview"
			Explore.animate
				properties:
					y: 200
					blur: 80
					opacity: 0
			navbar("dayview")
			Navigation.animate
				properties: {y: navigationY}

navbar = (target) ->
	navbar.currentState = target
	switch target
		when "home"
			backToSearchButton.visible = false
			searchForm.visible = true
			searchButton.visible = true
			navbarTitle.visible = false
			Navigation.animate
				properties: {height: 100}
			navbg.animate
				properties: {height: 100}

		when "home-search"
			backToSearchButton.visible = false
			searchForm.visible = true
			searchButton.visible = true
			navbarTitle.visible = false
			Navigation.animate
				properties: {height: 500}
			navbg.animate
				properties: {height: 500}

		when "dayview"
			backToSearchButton.visible = true
			searchForm.visible = false
			searchButton.visible = false
			navbarTitle.html = title("Results")
			navbarTitle.visible = true
			Navigation.animate
				properties: {height: 100}
			navbg.animate
				properties: {height: 100}

		when "explore"
			backToSearchButton.visible = true
			searchForm.visible = false
			searchButton.visible = false
			navbarTitle.html = title("Explore")
			navbarTitle.visible = true
			Navigation.animate
				properties: {height: 100}
			navbg.animate
				properties: {height: 100}

title = (label) ->
	"<div style='width: 200px; text-align: center; color: #333; font-size: 36px;'>#{label}</div>"



# Selected cards stack
# --------------------


# Selected cards stack
selectedCardsStack = new Layer
	width: Screen.width / 2
	height: cardSpacing * 2 + selectedHeight
	backgroundColor: "transparent"
	superLayer: Explore

# Listen to pinch out and expand if collapsed
selectedCardsStack.on Events.PinchOut, ->
	selectedCardsStack.expanding = true
	expandCardStack()

# Listen to pinch in and collapse if expanded
selectedCardsStack.on Events.PinchIn, ->
	collapseCardStack()

# Expand stack into grid
expandCardStack = () ->
	selectedRows = selectedCards.length // cols
	i = 0

	selectedCardsStack.width = Screen.width
	selectedCardsStack.height = Screen.height
	relatedCardsGrid.animate
		properties: {opacity: 0; blur: 80}
	map.animate
		properties: {opacity: 0; blur: 80}
	
	# to grid
	for row in [0..selectedRows]
		for col in [0...cols]
			# listen to card click to collapse
			selectedCards[i].on(Events.Click, onSelectedCardClicked)
			selectedCards[i].animate
				properties:
					width: cardWidth
					height: cardHeight
					rotationZ: 0
					x: cardSpacing + col * (cardWidth + cardSpacing)
					y: cardSpacing + row * (cardHeight + cardSpacing)
			if i + 1 is selectedCards.length
				break
			else
				i++

# Collapse grid into stack with clicked selected on top if clicked
onSelectedCardClicked = (event, layer) ->
	# collapse on click only if not animating (expand/collapse finished) and we are in grid not stack (card is small)
	if not layer.isAnimating and layer.width is cardWidth
		layer.bringToFront()
		collapseCardStack()
				
# Collapse grid into stack
collapseCardStack = () ->
	relatedCardsGrid.animate
		properties: {opacity: 1; blur: 0}
	map.animate
		properties: {opacity: 1; blur: 0}
	selectedCardsStack.animate
		properties:
			width: Screen.width / 2
			height: cardSpacing * 2 + selectedHeight
	
	# to stack
	for card in selectedCards
		card.animate
			properties:
				width: selectedWidth
				height: selectedHeight
				rotationZ: Utils.randomNumber(-5, 5)
				x: selectedX
				y: selectedY




# Related grid layer
# ------------------


makePOILayer = (fromX, fromY, fromWidth, fromHeight, fromColor) ->
	
	# Clone current grid for fade out animation
	relatedCardsGridPrevious = relatedCardsGrid.copy()
	relatedCardsGridPrevious.scrollY = relatedCardsGrid.scrollY
	relatedCardsGridPrevious.animate
		properties:
			scale: 0.9
			opacity: 0
			blur: 80

	# Reset current grid's scroll and hide until it is populated with new cards
	relatedCardsGrid.scrollY = 0
	relatedCardsGrid.visible = false

	# Delete previous grid after faded out
	relatedCardsGridPrevious.on Events.AnimationEnd, ->
		relatedCardsGridPrevious.visible = false
		relatedCardsGridPrevious.destroy()

		# Reveal current grid
		relatedCardsGrid.visible = true
		Utils.delay 0.2, ->
			grid.animate
				properties:
					y: selectedHeight + 2 * cardSpacing

	# Reveal map
	unless map.visible
		map.visible = true
		map.animate
			properties:
				scale: 1
				opacity: 1
				blur: 0

	# Move Navigation to top if necessary
	if Navigation.y isnt navigationY
		Navigation.animate
			properties: { y: navigationY }
		navbar("explore")
	
	# Create a new selected card to fly to position later, and position it above clicked POI or card
	selectedCards[selectedCards.length] = new Layer
		width: fromWidth
		height: fromHeight
		x: fromX
		y: fromY
		backgroundColor: fromColor
		superLayer: Explore
	
	selected = selectedCards[selectedCards.length - 1]
	selected.borderRadius = poiWidth / 2 if fromWidth < cardWidth         # round edges if coming from a POI on map
	
	selected.shadowY = 2
	selected.shadowBlur = 6
	selected.shadowColor = "rgba(0,0,0,0.2)"

	# Animate selected in position
	selected.bringToFront()
	selected.animate
		properties:
			x: selectedX
			y: selectedY
			width: selectedWidth
			height: selectedHeight
			borderRadius: 0
			
	# Add selected to stack when arrived in position
	selected.on Events.AnimationEnd, ->
		@off Events.AnimationEnd
		@superLayer = selectedCardsStack
				
	# Rotate a bit all previous selected as a whole
	r = Utils.randomNumber(-5, 5)
	if selectedCards.length > 1
		for i in [0..selectedCards.length - 2]
			selectedCards[i].animate
				properties:
					rotationZ: selectedCards[i].rotationZ + r
				curve: "spring(800,80,0)"

	# Delete previous grid of cards
	relatedCardsGrid.subLayers[0].destroy()

	# Create new grid for related cards
	grid = new Layer
		width: Screen.width
		height: rows * (cardHeight + cardSpacing)
		y: Screen.height
		backgroundColor: "transparent"
		superLayer: relatedCardsGrid

	# Populate grid with cards
	for row in [0..rows - 1]
		for col in [0..cols - 1]
			card = new Layer
				width: cardWidth
				height: cardHeight
				x: cardSpacing + col * (cardWidth + cardSpacing)
				y: row * (cardHeight + cardSpacing)
				superLayer: grid
				backgroundColor: Utils.randomColor()
			card.shadowY = 2
			card.shadowBlur = 6
			card.shadowColor = "rgba(0,0,0,0.2)"
			
			# Card click event handling
			card.on Events.Click, ->
				@visible = false
				# add POI to map for clicked card
				poi = new Layer
					width: poiWidth
					height: poiHeight
					x: Utils.randomNumber(poiWidth, mapContent.width - poiWidth)
					y: Utils.randomNumber(poiHeight, mapContent.height - poiHeight)
					superLayer: mapContent
					backgroundColor: this.backgroundColor
					borderRadius: poiWidth / 2
				# center map on POI
				mapContent.animate
					properties:
						x: map.width / 4 * 3 - cardSpacing / 2 - poi.x - poiWidth / 2
						y: map.height / 2 - poi.y - poiHeight / 2
					time: 0.4
				# create new canvas
				makePOILayer(
					@x, 
					-relatedCardsGrid.scrollY + grid.y + @y, 
					@width, 
					@height, 
					@backgroundColor
				)

	# Hide selected & map if scrolled
	relatedCardsGrid.on Events.Scroll, ->		
		map.opacity = selectedCardsStack.opacity = Utils.modulate(relatedCardsGrid.scrollY, [0, cardSpacing * 2], [1, 0], true)
		map.blur    = selectedCardsStack.blur    = Utils.modulate(relatedCardsGrid.scrollY, [0, cardSpacing * 2], [0, 10], true)
		
		# reorder layers when scrolled
		if relatedCardsGrid.scrollY > 0
			selectedCardsStack.bringToFront()
			relatedCardsGridPrevious.bringToFront()
			relatedCardsGrid.bringToFront()
			selected.bringToFront()
			Navigation.bringToFront()
		else
			map.bringToFront()
			selectedCardsStack.bringToFront()
			relatedCardsGridPrevious.bringToFront()
			selected.bringToFront()
			Navigation.bringToFront()




# Inspiration grid layer
# ----------------------


makeInspirationLayer = () ->

	# Reset
	relatedCardsGrid.scrollY = 0
	relatedCardsGrid.off(Events.Scroll, onInspirationGridScrolled)
	map.visible = false
	child.destroy() for child in relatedCardsGrid.subLayers
	child.destroy() for child in selectedCardsStack.subLayers
	child.destroy() for child in mapContent.subLayers
	selectedCards = []
	selectedCardsStack.width = Screen.width / 2
	selectedCardsStack.height = cardSpacing * 2 + selectedHeight
	relatedCardsGrid.opacity = 1
	relatedCardsGrid.blur = 0
	map.opacity = 1
	map.blur = 0

	# Related cards container
	grid = new Layer
		width: Screen.width
		height: rows * (cardHeight + cardSpacing)
		y: Screen.height - (2 * cardSpacing + cardHeight / 2)
		backgroundColor: "transparent"
		superLayer: relatedCardsGrid
				
	# Create grid of related cards
	for row in [0..rows - 1]
		for col in [0..cols - 1]
			card = new Layer
				# size and position
				width: cardWidth
				height: cardHeight
				x: cardSpacing + col * (cardWidth + cardSpacing)
				y: row * (cardHeight + cardSpacing)
				superLayer: grid
				image: getCardImage()
				
				# format cards
				backgroundColor: Utils.randomColor()
				
			card.shadowY = 2
			card.shadowBlur = 6
			card.shadowColor = "rgba(0,0,0,0.2)"
			
			card.on Events.Click, ->
				@visible = false
				# add POI to map for clicked card
				poi = new Layer
					width: poiWidth
					height: poiHeight
					x: Utils.randomNumber(poiWidth, mapContent.width - poiWidth)
					y: Utils.randomNumber(poiHeight, mapContent.height - poiHeight)
					superLayer: mapContent
					backgroundColor: @backgroundColor
					borderRadius: poiWidth / 2
				# center map on POI
				mapContent.animate
					properties:
						x: map.width / 4 * 3 - cardSpacing / 2 - poi.x - poiWidth / 2
						y: map.height / 2 - poi.y - poiHeight / 2
					time: 0.4
				# create new canvas
				makePOILayer(
					@x, 
					-relatedCardsGrid.scrollY + grid.y + @y, 
					@width, 
					@height, 
					@backgroundColor
				)

			# create initial set of POIs on map
			poi = new Layer
				width: poiWidth
				height: poiHeight
				x: Utils.randomNumber(0, mapContent.width)
				y: Utils.randomNumber(0, mapContent.height)
				superLayer: mapContent
				backgroundColor: card.backgroundColor
				borderRadius: poiWidth / 2
				
			poi.on Events.Click, ->
				mapContent.animate
					properties:
						x: map.width / 4 * 3 - cardSpacing / 2 - @x - poiWidth
						y: map.height / 2 - @y - poiHeight / 2
					time: 0.4
				makePOILayer(
					map.x + mapContent.x + @x, 
					map.y + mapContent.y + @y, 
					@width, 
					@height, 
					@backgroundColor
				)
	
	# Add fader at the bottom of map
	mapFader = new Layer
		width: map.width
		height: 200
		y: map.height - 200
		backgroundColor: "transparent"
		superLayer: map
	mapFader.image = "images/map_bottom_fader.png"

	# Move Navigation to top if scrolled
	relatedCardsGrid.on(Events.Scroll, onInspirationGridScrolled)


# Stick Navigation to top if inspiration grid was scrolled enough
onInspirationGridScrolled = (event, layer) ->
	if navbar.currentState is "home"
		Navigation.y = Screen.height // 3 - this.scrollY // 2
		if Navigation.y <= navigationY
			Navigation.y = navigationY
			relatedCardsGrid.off(Events.Scroll, onInspirationGridScrolled)
			navbar("explore")
	if navbar.currentState is "home-search"
		navbar("explore")




# Render UI
# ---------

goto("home")
