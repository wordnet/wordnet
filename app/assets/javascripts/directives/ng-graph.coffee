App = angular.module('wordnet')

App.directive 'wordnetGraph', ($timeout) ->
  scope: true

  controller: ['$scope', '$element', ($scope, $element) ->
    $scope.nodes = $scope.graphData.nodes
    $scope.links = $scope.graphData.links

    $scope.graph = Viva.Graph.graph()

    $scope.panToNode = (node) ->
      pos = $scope.graph.layout.getNodePosition(node.id)
      $scope.graph.renderer.moveTo(pos.x, pos.y) if pos

    $scope.selectNode = (node) ->
      $scope.graph.selectedNode = node
      $scope.panToNode(node)
  ]

App.directive 'graphCanvas', ($compile, $rootScope, $translate, $stateParams, getGraph) ->
  nodeIds = [$stateParams.queryId]

  restrict: 'EA'

  scope: true

  controller: ['$scope', ($scope) ->
    $scope.graphLinks = {}
    $scope.graphNodes = {}
    $scope.linkLengths = {}

    $scope.nodeTemplates = []

    scopes = {}

    ctrl = $scope.ctrl = {}

    graph = ctrl.graph = $scope.graph

    graph.geometry = Viva.Graph.geom()

    graph.layout = Viva.Graph.Layout.forceDirected graph,
      springLength : 400,
      springCoeff : 0.0002,
      dragCoeff : 0.1,
      gravity : -100,
      stableThreshold: 0.0002
      springTransform: (link, spring) ->
        spring.length = 200 * (1 - $scope.linkLengths[link.data.id])

    graph.graphics = Viva.Graph.View.svgGraphics()

    graph.graphics.node (node) ->

      container = Viva.Graph.svg('g')
        .attr('width', "125")
        .attr('height', "38")
        .attr('viewBox', '34.5 80 850 82')

      container.addEventListener 'dblclick', ->
        if _.contains(nodeIds, node.data.id)
          return if nodeIds.length == 1
          nodeIds = _.without(nodeIds, node.data.id)
        else
          nodeIds.push(node.data.id)

        getGraph(nodeIds).then (data) ->
          $scope.nodes = data.nodes
          $scope.links = data.links

      container.append(
        Viva.Graph.svg('path')
          .attr('fill', 'black')
          .attr('d', 'm43.30991,0.90535l5.80392,-0.77601l1.42268,-0.12934l23.28031,0l3.70222,0.37184l22.61747,2.84537l21.72829,2.66754l2.5867,0.38801l0.04851,8.03494l0,14.87353l-0.04851,2.71604l-6.19191,0.79218l-27.59687,3.42738l-15.71421,2.02086l-24.25033,0.01617l-3.23338,-0.388l-41.29022,-5.15724l-5.62608,-0.71134l-0.0485,-0.93768l0,-21.82529l0.0485,-2.86154l5.20574,-0.67901l37.55567,-4.6884z')
      )

      color = switch node.data.part_of_speech
        when "noun_pl", "noun_pwn" then '#ABFFAE'
        when "verb_pl", "verb_pwn" then '#FED25C'
        when "adjective_pl", "adjective_pwn" then '#ACFFEA'
        else "#FFFFFF"

      if _.contains(nodeIds, node.data.id)
        color = '#FFB2B2'

      container.append(
        Viva.Graph.svg('path')
          .attr('fill', color)
          .attr('d', 'm5.96441,6.79817l43.47275,-5.43207l12.96584,12.38383l13.15984,-12.4l37.26466,4.67223l6.19193,0.80834l-7.24277,10.83181l-0.85684,1.45502l1.13168,1.74603l5.30273,7.93793l1.68137,2.55437l-40.99923,5.10873l-2.9262,0.3395l-0.63051,-0.38801l-12.04433,-12.01199l-1.56819,1.51968l-10.1043,10.26597l-1.19635,0.59818l-41.09622,-5.1249l-2.45737,-0.35567l0.85685,-1.35802l6.03025,-8.98879l1.19635,-1.84302l-0.93768,-1.55202l-7.19426,-10.76715z')
      )

      top_empty = Viva.Graph.svg('path')
        .attr('fill', "blue")
        .attr('d', 'm51.43275,1.36207l10.96584,10.4l11.15984,-10.4z')

      top_half = Viva.Graph.svg('path')
        .attr('fill', "red")
        .attr('d', 'm51.43275,1.36207l10.96584,10.4l0,-10.4z')
        .attr('style', 'display: none')

      top_full = Viva.Graph.svg('path')
        .attr('fill', "red")
        .attr('d', 'm51.43275,1.36207l10.96584,10.4l11.15984,-10.4z')
        .attr('style', 'display: none')


      bottom_empty = Viva.Graph.svg('path')
        .attr('fill', "blue")
        .attr('d', 'm51.43275,36.80l10.96584,-10.4l11.15984,10.4z')

      bottom_half = Viva.Graph.svg('path')
        .attr('fill', "red")
        .attr('d', 'm51.43275,36.80l10.96584,-10.4l0,10.4z')
        .attr('style', 'display: none')

      bottom_full = Viva.Graph.svg('path')
        .attr('fill', "red")
        .attr('d', 'm51.43275,36.80l10.96584,-10.4l11.15984,10.4z')
        .attr('style', 'display: none')


      left_empty = Viva.Graph.svg('path')
        .attr('fill', "blue")
        .attr('d', 'm2,30.9l2.7,0.35l0.85685,-1.35802l6.03025,-8.98879l1.19635,-1.84302l-0.93768,-1.55202l-7.19426,-10.76715l-2.7,0.35z')

      left_half = Viva.Graph.svg('path')
        .attr('fill', "red")
        .attr('d', 'm2,18.9l10.78345,0l-0.93768,-1.55202l-7.19426,-10.76715l-2.7,0.35z')
        .attr('style', 'display: none')

      left_full = Viva.Graph.svg('path')
        .attr('fill', "red")
        .attr('d', 'm2,30.9l2.7,0.35l0.85685,-1.35802l6.03025,-8.98879l1.19635,-1.84302l-0.93768,-1.55202l-7.19426,-10.76715l-2.7,0.35z')
        .attr('style', 'display: none')


      right_empty = Viva.Graph.svg('path')
        .attr('fill', "blue")
        .attr('d', 'm123,30.9l-2.7,0.35l-0.85685,-1.35802l-6.03025,-8.98879l-1.19635,-1.84302l0.93768,-1.55202l7.19426,-10.76715l2.7,0.35z')

      right_half = Viva.Graph.svg('path')
        .attr('fill', "red")
        .attr('d', 'm123,18.9l-10.78345,0l0.93768,-1.55202l7.19426,-10.76715l2.7,0.35z')
        .attr('style', 'display: none')

      right_full = Viva.Graph.svg('path')
        .attr('fill', "red")
        .attr('d', 'm123,30.9l-2.7,0.35l-0.85685,-1.35802l-6.03025,-8.98879l-1.19635,-1.84302l0.93768,-1.55202l7.19426,-10.76715l2.7,0.35z')
        .attr('style', 'display: none')

      states =
        top: [top_empty, top_half, top_full]
        right: [right_empty, right_half, right_full]
        bottom: [bottom_empty, bottom_half, bottom_full]
        left: [left_empty, left_half, left_full]

      for name, list of states
        container.append(state) for state in list

      container.setState = (direction, number) ->
        for state in states[direction]
          state.style.display = "none"

        [0..number].forEach (i) ->
          states[direction][i].style.display = "block"

      container.onclick = (e) ->
        console.log(e, e)

      label = Viva.Graph.svg('text')
        .attr('font-family', 'verdana')
        .attr('font-size', 12.5)
        .attr('text-anchor', 'middle')
        .attr('x', 125 / 2)
        .attr('y', 23)
        .text("#{node.data.lemma[0..10]} #{node.data.sense_index}")

      if node.data.target_type != "synset"
        label.attr("style", "font-weight: bold")

      container.append(label)

      container

    graph.graphics.placeNode (nodeUI, pos) ->
      x = pos.x - 125 / 2
      y = pos.y - 38 / 2

      nodeUI.attr('transform', 'translate(' + x + ',' + y + ')')

      bbox = nodeUI.getBBox()

      nodeUI
        .attr('x', pos.x - bbox.width / 2)
        .attr('y', pos.y + bbox.height / 2)

    graph.graphics.link (link) ->
      label = Viva.Graph.svg("text").text("")
        # text($translate.instant("relation_#{link.data.id}"))

      graph.graphics.getSvgRoot().childNodes[0].append(label)

      path = Viva.Graph.svg("path").
        attr("stroke", $scope.relations[link.data.relation_id].color).
        attr("marker-end", "url(#Triangle#{link.data.relation_id})")

      path.label = label

      path

    graph.graphics.placeLink (linkUI, fromPos, toPos) ->
      toNodeSize = [125, 38]
      fromNodeSize = [125, 38]
      labelSize = [Number(linkUI.attr("width")), Number(linkUI.attr("height"))]

      from = graph.geometry.intersectRect(
        fromPos.x - fromNodeSize[0] / 2,
        fromPos.y - fromNodeSize[1] / 2,
        fromPos.x + fromNodeSize[0] / 2,
        fromPos.y + fromNodeSize[1] / 2,
        fromPos.x, fromPos.y,
        toPos.x,
        toPos.y
      ) or fromPos

      to = graph.geometry.intersectRect(
        toPos.x - toNodeSize[0] / 2,
        toPos.y - toNodeSize[1] / 2,
        toPos.x + toNodeSize[0] / 2,
        toPos.y + toNodeSize[1] / 2,
        toPos.x,
        toPos.y,
        fromPos.x,
        fromPos.y
      ) or toPos

      data = "M" + from.x + "," + from.y + "L" + to.x + "," + to.y

      linkUI.attr "d", data

    $scope.ctrl.updateNodes =  (nodes, oldNodes) ->
      return if nodes == oldNodes

      indexedNodes = _.indexBy(nodes, 'id')
      indexedOldNodes = _.indexBy(oldNodes, 'id')

      nodesIds = nodes.map (node) -> node.id
      oldNodesIds = oldNodes.map (node) -> node.id

      newNodes = _.difference(nodesIds, oldNodesIds).map((id) -> indexedNodes[id])
      removedNodes = _.difference(oldNodesIds, nodesIds).map((id) -> indexedOldNodes[id])

      removedNodes.forEach (node) ->
        delete $scope.graphNodes[node.id]
        graph.removeNode(node.id)

      nodes.forEach (node) ->
        $scope.graphNodes[node.id] = node
        graph.addNode(node.id, node)

    $scope.ctrl.updateLinks =  (links, oldLinks) ->
      return if links == oldLinks

      indexedLinks = _.indexBy(links, 'id')
      indexedOldLinks = _.indexBy(oldLinks, 'id')

      groupedSources = _.groupBy(links, 'source_id')
      groupedTargets = _.groupBy(oldLinks, 'target_id')

      linksIds = _.keys(indexedLinks)
      oldLinksIds = _.keys(indexedOldLinks)

      newLinks = _.difference(linksIds, oldLinksIds).map((id) -> indexedLinks[id])
      removedLinks = _.difference(oldLinksIds, linksIds).map((id) -> indexedOldLinks[id])

      removedLinks.forEach (link) ->
        graphLink = $scope.graphLinks[link.id]
        graph.removeLink(graphLink) if graphLink

      newLinks.forEach (link) ->
        $scope.linkLengths[link.id] = 1 + 0.1 * (
          groupedSources[link.source_id]?.length || 0 +
          groupedSources[link.target_id]?.length || 0 +
          groupedTargets[link.source_id]?.length || 0 +
          groupedTargets[link.target_id]?.length || 0
        )

        graphLink = graph.addLink(link.source_id, link.target_id, link)
        $scope.graphLinks[link.id] = graphLink

    $scope.$watchCollection 'nodes', (nodes, oldNodes) ->
      return if nodes == oldNodes
      ctrl.updateNodes(nodes, oldNodes)

    $scope.$watchCollection 'links', (links, oldLinks) ->
      return if links == oldLinks
      ctrl.updateLinks(links, oldLinks)

    ctrl.updateNodes($scope.nodes, [])
    ctrl.updateLinks($scope.links, [])

    $scope
  ]

  link: ($scope, $element, $attributes) ->
    graph = $scope.graph

    graph.renderer = Viva.Graph.View.renderer graph,
      graphics: graph.graphics
      layout: graph.layout
      container: $element[0]

    graph.renderer.run()

    createMarker = (id, color = "black") ->
      marker = Viva.Graph.svg("marker").
        attr("id", id).
        attr("viewBox", "0 0 20 20").
        attr("refX", "20").
        attr("refY", "10").
        attr("markerUnits", "strokeWidth").
        attr("markerWidth", "20").
        attr("markerHeight", "10").
        attr("orient", "auto").
        attr("fill", color)

      marker.append("path").
        attr("d", "M 0 0 L 20 10 L 0 20 z")

      marker

    defs = graph.graphics.getSvgRoot().append("defs")

    for id, relation of $scope.relations
      marker = createMarker("Triangle#{relation.id}", relation.color)
      defs.append(marker)

App.directive 'nodeTemplate', ->

  restrict: 'EA'

  require: '^graphCanvas'

  link: ($scope, $element, $attributes, graph) ->
    graph.nodeTemplates.push(
      pattern: new RegExp($attributes.nodeTemplate)
      html: $element.html()
    )
