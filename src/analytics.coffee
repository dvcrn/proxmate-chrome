root = exports ? this
root._gaq = [['_setAccount', 'UA-31118328-8'], ['_trackPageview']]

insertGAScript = ->
  ga = document.createElement 'script'
  ga.type = 'text/javascript'
  ga.src = "https://ssl.google-analytics.com/ga.js"

  s = document.getElementsByTagName 'head'
  s[0].appendChild ga

insertGAScript()
