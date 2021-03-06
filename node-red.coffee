module.exports = (env) ->
  http = env.require 'http'
  express = env.require 'express';
  RED = require 'node-red'

  class NodeRed extends env.plugins.Plugin

    init: (@app, @framework, @config) =>
      settings = {
        httpAdminRoot:"/red",
        httpNodeRoot: "/api/",
        userDir:__dirname + "/../../",
        nodesDir:[__dirname,__dirname + "/../../"],
        pimaticFramework:@framework,
        functionGlobalContext: { }
      }

      appie = express();
      appie.use("/",express.static("public"));
      server = http.createServer(appie);

      RED.init(server,settings)
      appie.use(settings.httpAdminRoot,RED.httpAdmin)
      appie.use(settings.httpNodeRoot,RED.httpNode)
      server.listen(@config.port);

      @framework.on 'server listen', (context)=>
        finished = true
        RED.start().catch (error) =>
          env.logger.error "Startup failed: ", error
        return

      @framework.once 'destroy', (context) =>
        context.waitForIt RED.stop()

  return new NodeRed
  
  