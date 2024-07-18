<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8" />
        <title>NACC</title>
        <link rel="shortcut icon" href="favicon.ico" />
        <link rel="icon" type="image/png" href="favicon-192x192.png" sizes="192x192" />
        <link rel="apple-touch-icon" href="apple-touch-icon-180x180.png" sizes="180x180" />                

        <script>
            /********************************************************************************************/
            /**
                \brief  This allows us to compare today to a given date.
                        
                        Cribbed from here: https://gist.github.com/clecuona/2945438
                
                \param  inFromDate The date that will be the one we compare against.
                        This date should always be earlier than the current date.
                
                \returns an object, with the total number of days, and the span, in years, months and days.
              */
            function makeDateSpan(inFromDate) {
                var difference = new Object;
                
                difference.totalDays = 0;
                difference.years = 0;
                difference.months = 0;
                difference.days = 0;
                
                var dt2 = new Date();
                var dt1 = inFromDate;
                
                if ( dt2 > dt1 ) {
                    difference.totalDays = parseInt((dt2.getTime() - dt1.getTime()) / 86400000);
                    
                    var year1 = dt1.getFullYear();
                    var year2 = dt2.getFullYear();
            
                    var month1 = dt1.getMonth();
                    var month2 = dt2.getMonth();
            
                    var day1 = dt1.getDate();
                    var day2 = dt2.getDate();
                    
                    difference.years = year2 - year1;
                    difference.months = month2 - month1;
                    difference.days = day2 - day1;
            
                    if ( difference.days < 0 ) {
                        // Use temporary date to get the number of days remaining in the month
                        var numDays = new Date(year1, month1 + 1, 1, 0, 0, -1).getDate();
            
                        difference.months -= 1;
                        difference.days += numDays;
                    };
                    
                    if ( difference.months < 0 ) {
                        difference.months += 12;
                        difference.years -= 1;
                    };
                };
                
                return difference;
            };
            
            /********************************************************************************************/
            /**
                \brief  This returns an array of image mortices to be used to represent the input datespan.
                                        
                \param  inDateSpan The datespan (from the dateSpan function).
                \param  inIsHorizontalLayout If true, the images will be set up for horizontal layout (closed top).
                
                \returns an array of objects, with the following properties:
                
                            - ring: It is the name of the ring (open top or closed top).
                            - tagBody: This will be the name for the selected tag body.
                            - tagText: The name of the text image for the body.
              */
            function imagesForDateSpan(inDateSpan, inIsHorizontalLayout) {
                var ret = buildListForDays(inDateSpan, inIsHorizontalLayout);
                
                ret = buildListForMonths(ret, inDateSpan, inIsHorizontalLayout);
                
                ret = buildListForYears(ret, inDateSpan, inIsHorizontalLayout);

                return ret;
            }
            
            /********************************************************************************************/
            /**
             Builds a list of tags for the first part of the chain (days).
             
             \param  inIsHorizontalLayout If true, the images will be set up for horizontal layout (closed top).
             \param  inDateSpan The datespan (from the dateSpan function).

             \returns an array of objects, with the following properties:
             
                         - ring: It is the name of the ring (open top or closed top).
                         - tagBody: This will be the name for the selected tag body.
                         - tagText: The name of the text image for the body.
              */
            function buildListForDays(inDateSpan, inIsHorizontalLayout) {
                var ret = new Array();
                
                if (0 < inDateSpan.totalDays) {
                    ret.push(imageForDays(1, true));
                    
                    if (29 < inDateSpan.totalDays) {
                        ret.push(imageForDays(30, inIsHorizontalLayout));
                        
                        if (59 < inDateSpan.totalDays) {
                            ret.push(imageForDays(60, inIsHorizontalLayout));
                            
                            if (89 < inDateSpan.totalDays) {
                                ret.push(imageForDays(90, inIsHorizontalLayout));
                            }
                        }
                    }
                }

                return ret;
            }
            
            /********************************************************************************************/
            /**
             Builds a list of tags for the next part of the chain (months).
             
             \param  inPreviousArray The previously-built array. We are adding to this.
             \param  inIsHorizontalLayout If true, the images will be set up for horizontal layout (closed top).
             \param  inDateSpan The datespan (from the dateSpan function).

             \returns an array of objects, with the following properties:
             
                         - ring: It is the name of the ring (open top or closed top).
                         - tagBody: This will be the name for the selected tag body.
                         - tagText: The name of the text image for the body.
              */
            function buildListForMonths(inPreviousArray, inDateSpan, inIsHorizontalLayout) {
                if ((0 < inDateSpan.years) || (5 < inDateSpan.months)) {
                    inPreviousArray.push(imageForMonths(6, inIsHorizontalLayout));
                    
                    if ((0 < inDateSpan.years) || (8 < inDateSpan.months)) {
                        inPreviousArray.push(imageForMonths(9, inIsHorizontalLayout));
                    }
                }

                return inPreviousArray;
            }
            
            /********************************************************************************************/
            /**
             Builds a list of tags for the next part of the chain (years).
             
             \param  inPreviousArray The previously-built array. We are adding to this.
             \param  inIsHorizontalLayout If true, the images will be set up for horizontal layout (closed top).
             \param  inDateSpan The datespan (from the dateSpan function).

             \returns an array of objects, with the following properties:
             
                         - ring: It is the name of the ring (open top or closed top).
                         - tagBody: This will be the name for the selected tag body.
                         - tagText: The name of the text image for the body.
              */
            function buildListForYears(inPreviousArray, inDateSpan, inIsHorizontalLayout) {
                if (0 < inDateSpan.years) {
                    inPreviousArray.push(imageForYears(1, inIsHorizontalLayout));
                
                    if (((1 == inDateSpan.years) && (5 < inDateSpan.months)) || (1 < inDateSpan.years)) {
                        inPreviousArray.push(imageForMonths(18, inIsHorizontalLayout));
                    }

                    for (year = 2; year <= inDateSpan.years; year++) {
                        if (5 == year) {
                            inPreviousArray.push(imageForYears(5, inIsHorizontalLayout));
                        } else if (10 == year) {
                            inPreviousArray.push(imageForYears(10, inIsHorizontalLayout));
                        } else if (15 == year) {
                            inPreviousArray.push(imageForYears(15, inIsHorizontalLayout));
                        } else if (20 == year) {
                            inPreviousArray.push(imageForYears(20, inIsHorizontalLayout));
                        } else if (25 == year) {
                            inPreviousArray.push(imageForYears(25, inIsHorizontalLayout));
                        } else if (30 == year) {
                            inPreviousArray.push(imageForYears(30, inIsHorizontalLayout));
                        } else if (35 == year) {
                            inPreviousArray.push(imageForYears(35, inIsHorizontalLayout));
                        } else if (40 == year) {
                            inPreviousArray.push(imageForYears(40, inIsHorizontalLayout));
                        } else if (45 == year) {
                            inPreviousArray.push(imageForYears(45, inIsHorizontalLayout));
                        } else if (50 == year) {
                            inPreviousArray.push(imageForYears(50, inIsHorizontalLayout));
                        } else {
                            inPreviousArray.push(imageForYears(2, inIsHorizontalLayout));
                        }
                    }
                }

                return inPreviousArray;
            }

            /********************************************************************************************/
            /**
                \brief  This returns a single image mortice object to be used to represent the input days.
                                        
                \param  inDays The number of days to be represented.
                \param  inIsClosed True, if the top of the ring is to be closed.
                
                \returns a single object, with the following properties:
                
                            - ring: It is the name of the ring (open top or closed top).
                            - tagBody: This will be the name for the selected tag body.
                            - tagText: The name of the text image for the body.
                            
                            Null is returned, if the given days are not one of the explicit targets.
              */
            function imageForDays(inDays, inIsClosed) {
                var ret = new Object;
                
                ret.ring = inIsClosed ? "ringClosed.png" : "ringOpen.png";
                
                switch (inDays) {
                    case 1:
                        ret.tagBody = "bodyWhite.png";
                        ret.tagText = "textOneDay.png";
                        break;
                        
                    case 30:
                        ret.tagBody = "bodyDaygloOrange.png";
                        ret.tagText = "textThirtyDays.png";
                        break;
                        
                    case 60:
                        ret.tagBody = "bodyDaygloGreen.png";
                        ret.tagText = "textSixtyDays.png";
                        break;
                        
                    case 90:
                        ret.tagBody = "bodyRed.png";
                        ret.tagText = "textNinetyDays.png";
                        break;
                        
                    case 10000:
                        ret.tagBody = "bodyPurple.png";
                        ret.tagText = "textTenThousandDays.png";
                        break;
                        
                    default:
                        ret = null;
                }
                
                return ret;
            }
            
            
            /********************************************************************************************/
            /**
                \brief  This returns a single image mortice object to be used to represent the input months.
                                        
                \param  inMonths The number of months to be represented.
                \param  inIsClosed True, if the top of the ring is to be closed.
                
                \returns a single object, with the following properties:
                
                            - ring: It is the name of the ring (open top or closed top).
                            - tagBody: This will be the name for the selected tag body.
                            - tagText: The name of the text image for the body.
             
                            Null is returned, if the given months are not one of the explicit targets.
              */
            function imageForMonths(inMonths, inIsClosed) {
                var ret = new Object;
                
                ret.ring = inIsClosed ? "ringClosed.png" : "ringOpen.png";
                
                switch (inMonths) {
                    case 6:
                        ret.tagBody = "bodyBlue.png";
                        ret.tagText = "textSixMonths.png";
                        break;
                        
                    case 9:
                        ret.tagBody = "bodyYellow.png";
                        ret.tagText = "textNineMonths.png";
                        break;
                        
                    case 18:
                        ret.tagBody = "bodyGray.png";
                        ret.tagText = "textEighteenMonths.png";
                        break;
                        
                    default:
                        ret = null;
                }
                
                return ret;
            }
            
            /********************************************************************************************/
            /**
                \brief  This returns a single image mortice object to be used to represent the input years.
                                        
                \param  inYears The number of years to be represented.
                \param  inIsClosed True, if the top of the ring is to be closed.
                
                \returns a single object, with the following properties:
                
                            - ring: It is the name of the ring (open top or closed top).
                            - tagBody: This will be the name for the selected tag body.
                            - tagText: The name of the text image for the body.
             
                            Null is returned, if the given years are not one of the explicit targets.
              */
            function imageForYears(inYears, inIsClosed) {
                var ret = new Object;
                
                ret.ring = inIsClosed ? "ringClosed.png" : "ringOpen.png";
                
                switch (inYears) {
                    case 1:
                        ret.tagBody = "bodyMoonglow.png";
                        ret.tagText = "textOneYear.png";
                        break;
                        
                    case 2:
                        ret.tagBody = "bodyBlack.png";
                        ret.tagText = "textMultiYear.png";
                        break;
                        
                    case 5:
                        ret.tagBody = "bodyBurntOrange.png";
                        ret.tagText = "textFiveYears.png";
                        break;
                        
                    case 10:
                        ret.tagBody = "bodySpeckled.png";
                        ret.tagText = "textTenYears.png";
                        break;
                        
                    case 15:
                        ret.tagBody = "bodyHunterGreen.png";
                        ret.tagText = "textFifteenYears.png";
                        break;
                        
                    case 20:
                        ret.tagBody = "bodyPurple.png";
                        ret.tagText = "textTwentyYears.png";
                        break;
                        
                    case 25:
                        ret.tagBody = "bodyHotPink.png";
                        ret.tagText = "textTwentyFiveYears.png";
                        break;

                    case 30:
                        ret.tagBody = "bodyMoonglow.png";
                        ret.tagText = "textThirtyYears.png";
                        break;
                        
                    case 35:
                        ret.tagBody = "bodyBurntOrange.png";
                        ret.tagText = "textThirtyFiveYears.png";
                        break;

                    case 40:
                        ret.tagBody = "bodyBlue.png";
                        ret.tagText = "textFortyYears.png";
                        break;

                    case 45:
                        ret.tagBody = "bodyYellow.png";
                        ret.tagText = "textFortyFiveYears.png";
                        break;

                    case 50:
                        ret.tagBody = "bodyGray.png";
                        ret.tagText = "textFiftyYears.png";
                        break;
                        
                    default:
                        ret = null;
                }
                
                return ret;
            }
            
            /********************************************************************************************/
            /**
                \brief  This creates a bunch of DOM objects, containing the tags that represent the datespan given.
                
                \param  inDateSpan The datespan (from the dateSpan function).
             
                \returns A div element, containing all the tags.
              */
            function makeDOMObjectsForDateSpan(inDateSpan) {
                var mainContainer = document.createElement("div");
                mainContainer.className = "nacc_keytags";
                
                function makeImages(inImageTagObject, inIndex, ignoredArray, inThisValue) {
                    var container = document.createElement("div");
                    container.className = 0 == inIndex ? "first keytag" : "next keytag";

                    var ring = document.createElement("img");
                    ring.className = "keytag_ring";
                    ring.src = "img/" + inImageTagObject.ring;
                    container.appendChild(ring);
                    
                    var tag = document.createElement("img");
                    tag.className = "keytag_tag";
                    tag.src = "img/" + inImageTagObject.tagBody;
                    container.appendChild(tag);

                    var text = document.createElement("img");
                    text.className = "keytag_text";
                    text.src = "img/" + inImageTagObject.tagText;
                    container.appendChild(text);

                    mainContainer.appendChild(container);
                }
                
                imagesForDateSpan(inDateSpan).forEach(makeImages)
                
                return mainContainer;
            }
            
            /********************************************************************************************/
            /**
                \brief  This parses the date from the input string, and displays tags, if required.
              */
            function makeADate() {
                var dateString = window.location.search.split('?')[1];
                if (null != dateString) {
                    var splitter = dateString.split('/');
                    if (0 < splitter.length) {
                        var date = new Date(splitter[0]);
                        if (null != date) {
                            var dateSpan = makeDateSpan(date);
                            if (0 < dateSpan.totalDays) {
                                document.getElementById("all_tags").appendChild(makeDOMObjectsForDateSpan(dateSpan));
                            }
                        }
                    }
                }
            }
        </script>
        <style>
            div.main_block {
                display: table;
                margin: auto;
            }
            
            div#all_tags {
            }
            
            div.nacc_keytags {
                margin: auto;
                width: 320px;
            }
            
            div.nacc_keytags div.keytag {
                display: grid;
                grid-template-rows: 320px;
                grid-template-columns: 580px;
            }
            
            div.nacc_keytags div.keytag img {
                display: block;
                grid-row: 1;
                grid-column: 1;
            }
            
            div.nacc_keytags div.next {
                margin-top: -135px;
            }
        </style>
    </head>
    <body style="text-align: center">
        <div class="main_block">
            <a href="https://littlegreenviper.com/portfolio/nacc/"><img src="favicon-192x192.png" alt="NACC Logo" /></a>
            <h2><a href="https://littlegreenviper.com/portfolio/nacc/">NACC</a></h2>
            <p><a href="https://littlegreenviper.com/portfolio/nacc/">The NACC is an iphone, iPad and Mac app that will calculate your cleantime.</a></p>
            <p><a href="https://apps.apple.com/us/app/nacc/id452299196">Get it on the Apple App Store.</a></p>
            <p><a href="https://apps.apple.com/us/app/nacc/id452299196"><img src="img/AppStore.png" /></a></p>
            <div id="all_tags"></div>
            <script> makeADate(); </script>
        </div>
    </body>
</html>
