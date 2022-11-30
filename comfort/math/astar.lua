-- ======================================================================
-- Copyright (c) 2012 RapidFire Studio Limited
-- All Rights Reserved.
-- http://www.rapidfirestudio.com

-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:

-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
-- CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
-- SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
-- ======================================================================

-- author: RapidFire Studio Limited, RobbiTheFox		current maintainer:RobbiTheFox		v1.0

AStar = {}

function AStar.GetDistance(_x1, _y1, _x2, _y2)

	return math.sqrt(math.pow(_x2 - _x1, 2) + math.pow(_y2 - _y1, 2))
end

function AStar.GetPathCost(_nodeA, _nodeB)

	return AStar.GetDistance(_nodeA.x, _nodeA.y, _nodeB.x, _nodeB.y)
end

function AStar.GetHeuristicCostEstimate(_nodeA, _nodeB)

	return AStar.GetDistance(_nodeA.x, _nodeA.y, _nodeB.x, _nodeB.y)
end

function AStar.IsValidNode(_node, _neighbor)

	return true
end

function AStar.GetLowestFScore(_set, _fScore)

	local lowest, bestNode = 1 / 0, nil
	for _, node in ipairs(_set) do
		local score = _fScore[node]
		if score < lowest then
			lowest, bestNode = score, node
		end
	end
	return bestNode
end

function AStar.GetNeighbourNodes(_currentNode, _nodes)

	local neighbors = {}
	for _, node in ipairs(_nodes) do
		if _currentNode ~= node and AStar.IsValidNode(_currentNode, node) then
			table.insert(neighbors, node)
		end
	end
	return neighbors
end

function AStar.NotIn(_set, _currentNode)

	for _, node in ipairs(_set) do
		if node == _currentNode then return false end
	end
	return true
end

function AStar.RemoveNode(_set, _currentNode)

	for i = table.getn(_set), 1, -1 do
		if _set[i] == _currentNode then
			table.remove(_set, i)
			break
		end
	end

	--for i, node in ipairs ( _set ) do
	--if node == _currentNode then
	--_set [ i ] = _set [ #_set ]
	--_set [ #_set ] = nil
	--break
	--end
	--end
end

function AStar.UnwindPath(_path, _map, _currentNode)

	if _map[_currentNode] then
		table.insert(_path, 1, _map[_currentNode])
		return AStar.UnwindPath(_path, _map, _map[_currentNode])
	else
		return _path
	end
end

function AStar.FindPath(_start, _goal, _nodes, _neighbourFunc, _costFunc)

	local closedset = {}
	local openset = { _start }
	local came_from = {}

	if _neighbourFunc then AStar.GetNeighbourNodes = _neighbourFunc end

	if _costFunc then AStar.GetPathCost = _costFunc end

	local g_score, f_score = {}, {}
	g_score[_start] = 0
	f_score[_start] = g_score[_start] + AStar.GetHeuristicCostEstimate(_start, _goal)

	while table.getn(openset) > 0 do

		local current = AStar.GetLowestFScore(openset, f_score)
		if current == _goal then
			local path = AStar.UnwindPath({}, came_from, _goal)
			table.insert(path, _goal)
			return path
		end

		AStar.RemoveNode(openset, current)
		table.insert(closedset, current)

		local neighbors = AStar.GetNeighbourNodes(current, _nodes)
		for _, neighbor in ipairs(neighbors) do
			if AStar.NotIn(closedset, neighbor) then

				local tentative_g_score = g_score[current] + AStar.GetPathCost(current, neighbor)

				if AStar.NotIn(openset, neighbor) or tentative_g_score < g_score[neighbor] then
					came_from[neighbor] = current
					g_score[neighbor] = tentative_g_score
					f_score[neighbor] = g_score[neighbor] + AStar.GetHeuristicCostEstimate(neighbor, _goal)
					if AStar.NotIn(openset, neighbor) then
						table.insert(openset, neighbor)
					end
				end
			end
		end
	end

	return nil -- no valid path
end
