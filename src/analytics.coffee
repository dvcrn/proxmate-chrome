root = exports ? this
root._gaq = [['_setAccount', 'UA-31118328-8'], ['_trackPageview']]

insertGAScript = ->
  ga = document.createElement 'script'
  ga.type = 'text/javascript'
  ga.async = true

  ga.src = "https://ssl.google-analytics.com/ga.js"

  s = document.getElementsByTagName 'script'
  s[0].parentNode.insertBefore ga, s

insertGAScript()