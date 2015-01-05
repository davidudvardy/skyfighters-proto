function makeImageUrl(index, json) {
	if(json.results.length > index) {
		if(json.results[index].photos != null) {
		    var photoReference = json.results[index].photos[0].photo_reference;
			var apiKey = "AIzaSyCZVfNWClFJBXGUELESnRJMkIKqpMpH0YM";
			var imageUrl = String.format('https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference={0}&key={1}', photoReference, apiKey);
			return imageUrl;
		}
		else {
			return "";
		}
	}
	else {
		return "";
	}
}

String.format = function() {
    // The string containing the format items (e.g. "{0}")
    // will and always has to be the first argument.
    var theString = arguments[0];
    
    // start with the second argument (i = 1)
    for (var i = 1; i < arguments.length; i++) {
        // "gm" = RegEx options for Global search (more than one instance)
        // and for Multiline search
        var regEx = new RegExp("\\{" + (i - 1) + "\\}", "gm");
        theString = theString.replace(regEx, arguments[i]);
    }
    
    return theString;
}

/** Unused functions
var cards;

function resetCards() {
	var map = new google.maps.Map(document.getElementById('map-canvas'));
	var service = new google.maps.places.PlacesService(map);
	var request = { query: 'museum' };
	service.textSearch(request, setCardImages);

	cards = [];
}

function addCard(card) {
	cards.push(card);
}

function setCardImages(results, status) {
	
	if (status == google.maps.places.PlacesServiceStatus.OK) {

		var placesCount = Math.min(results.length, cards.length);

	    for (var i = 0; i < placesCount; i++) {
		    var place = results[i];
		    var card = cards[i];

	    	var photoReference = place.photos[0].photo_reference;
	    	var apiKey = "AIzaSyCZVfNWClFJBXGUELESnRJMkIKqpMpH0YM";
	    	var imageUrl = String.format('https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference={0}&key={1}', photoReference, apiKey);
	    	card.image = imageUrl;
	    }
	}
}
**/