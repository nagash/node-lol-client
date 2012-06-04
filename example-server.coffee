# file: example-server.coffee
#
# This file contains a simple implementation of a REST interface on top of the LolClient.
# Each function is expressed as a path:
# /summoner/<name>         - getSummonerByName
# /stats/<acctId>          - getSummonerStats
# /history/<acctId>        - getMatchHistory
# /aggregate/<acctId>      - getAggregatedStats
# /teams/<summonerId>      - getTeamsForSummoner
# /team/<teamId>           - getTeamById
# /data/<acctId>           - getSummonerData

LolClient = require('./lol-client')
util = require('util')
url = require('url')
http = require('http')

# Config stuff
restServerPort = 9615
options =
  region: 'na' # Lol Client region, one of 'na', 'euw' or 'eune'
  username: 'your_leagueoflegends_username' # must be lowercase!
  password: 'your_leagueoflegends_password'
  version: '1.60.12_05_23_03_39' # Lol Client version - must be "current" or it wont work. This is correct as at 05/30/2012

summoner = {
  name: 'HotshotGG', # summoners name
  acctId: 434582, # returned from getSummonerByName and getSummonerById
  summonerId: 407750 # returned from getSummonerByName
  teamId: "TEAM-a1ebba15-986f-488a-ae2f-e081b2886ba4" # teamIds can be gotten from getTeamsForSummoner
}

client = new LolClient(options)

# Listen for a successful connection event
client.on 'connection', ->
  console.log 'Connected'
  
  # Now do stuff!
  serv = http.createServer (req, res) ->
    urlparts = url.parse req.url
    urlfolds = urlparts.pathname.split '/'
    if urlfolds.length != 3
      res.writeHead 404, {'content-type': 'text/plain'}
      res.end '404 Not Found\n'
      return
    mapping =
      summoner: client.getSummonerByName
      stats: client.getSummonerStats
      history: client.getMatchHistory
      aggregate: client.getAggregatedStats
      teams: client.getTeamsForSummoner
      team: client.getTeamById
      data: client.getSummonerData

    func = mapping[urlfolds[1]]
    if func? 
      res.writeHead 200, {'content-type': 'text/json'}
      func decodeURIComponent(urlfolds[2]), (err, result) ->
        res.end JSON.stringify(result)
    else
      res.writeHead 404, {'content-type': 'text/plain'}
      res.end '404 Not Found\n'
  serv.listen restServerPort

client.connect() # Perform connection
