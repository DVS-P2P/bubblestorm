#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import logging
import math
import time
import unittest

log = logging.getLogger(__name__)

class NodePlacement(object):
	'''
	the node-host placement
	
	wraps datastructures
	'''
	
	def __init__(self, hosts, nodeGroups, prototypes, nodegroupHostRelations):
		'''
		maps liveexp/models to local internal models
		'''
		self.hosts = dict()
		for host in hosts:
			cpuArch = Host.ARCH_64 if host.is64Bit() else Host.ARCH_32
			maxMembers = min(host.getNodePlaces(), len(host.getCheckedPorts()), host.getMaxNodes())
			freeDisc = 0.9 * host.getFreeDisc()
			availableRAM = 0.9 * host.getFreeRam()
			rankingPoints = host.getRankingPoints()

			self.hosts[host] = Host(maxMembers, cpuArch, freeDisc, availableRAM, rankingPoints)

		self.nodeGroups = dict()
		self.nodeGroupsReverse = dict()
		self.nodeGroupsNames = dict()
		for group in nodeGroups:
			self.nodeGroups[group] = Group(group.getAlias())
			self.nodeGroups[group].setMembersCount(group.getRelevantGroupSize())
			self.nodeGroupsReverse[self.nodeGroups[group]] = group
			if group.getAlias() not in self.nodeGroupsNames:
				self.nodeGroupsNames[group.getAlias()] = []
			self.nodeGroupsNames[group.getAlias()].append(self.nodeGroups[group])


		
		self.contracts = []
		for relation in nodegroupHostRelations:
			aliasA, aliasB = relation.getGroupNames()
			rel = Contract.exclusion if relation.isExclusion() else Contract.bound
			for groupA in self.nodeGroupsNames[aliasA]:
				for groupB in self.nodeGroupsNames[aliasB]:
					self.contracts.append(Contract(rel, groupA, groupB))

		
		self.prototypes = dict()
		for prototype in prototypes:
			cmd = prototype.command()
			ram = prototype.getReqRam()
			hd = prototype.getReqDisc()
			cpuArch = Host.ARCH_64 if prototype.is64Bit() else Host.ARCH_32
			if cmd not in self.prototypes:
				self.prototypes[cmd] = []
			self.prototypes[cmd].append(Prototype(cpuArch, hd, ram))

		for group in nodeGroups:
			cmd = group.prototypeCommand()
			ratio = group.onlineRatio()
			for prototype in self.prototypes[cmd]:
				ratio = 1 # hier mit ratio den verbrauch anzupassen hat sich als keine gute idee herausgestellt
				ram = int(prototype.reqRAM * ratio)
				hd = prototype.reqDisc
				cpuArch = prototype.cpuArch
				proto = Prototype(cpuArch, hd, ram)
				self.nodeGroups[group].addPrototype(proto)

			
	def processGroupsWithRelations(self):
		'''
		process group-group relations
		'''
		self.groupRelationsProcessing = GroupRelationsProcessing(self.nodeGroups.values(), self.contracts)	
		self.groupRelationsProcessing.processGroups()	
	
	def placementNonGreedy(self):
		'''
		make node-host assignment, use as less as possible hosts
		'''
		strategy = HostPatternManager.STRATEGY_USE_AS_LESS_AS_POSSIBLE
		self.patternManager = self.groupRelationsProcessing.getPatternManager()
		self.patternManager.placement(self.hosts.values(), strategy)
		
	def placementGreedy(self):
		'''
		make node-host assignment, use as many as possible hosts
		'''
		strategy = HostPatternManager.STRATEGY_USE_AS_MANY_AS_POSSIBLE
		self.patternManager = self.groupRelationsProcessing.getPatternManager()
		self.patternManager.placement(self.hosts.values(), strategy)
	
	def processBookings(self):
		'''
		transver: internal bookings - liveexp/models
		'''
		for (realHost, host) in self.hosts.items():
			for booking in host.bookings:
				for (group, amount) in booking.order.items():
					realHost.assignNodeGroup(self.nodeGroupsReverse[group], amount, add=True)
					self.nodeGroupsReverse[group].modifyAssignedNodes(amount, add=True)
		
		
		

'''
define private models with logic
'''

class Contract(object):
	'''
	a group-group contract
	'''

	exclusion = "exclusion"
	bound = "bound"
	
	def __repr__(self):
		return 'link<{0},{1},{2}>'.format(self.link,self.groupA,self.groupB)

	def __init__(self, link, groupA, groupB):
		self.link = link
		self.groupA = groupA
		self.groupB = groupB
		
		if self.groupA == self.groupB and self.isExclusion():
			self.groupA.setMax(1)
		
		if self.groupA == self.groupB and self.isBound():
			self.groupA.setMin(2)
		
		self.groupA.addContract(self)
		self.groupB.addContract(self)
		
	# Placement
	
	def matchGroup(self, group):
		return self.groupA == group or self.groupB == group
	
	def isBound(self):
		return self.link == Contract.bound
	
	def isExclusion(self):
		return self.link == Contract.exclusion
	
	def otherGroup(self, group):
		if group == self.groupA:
			return self.groupB
		elif group == self.groupB:
			return self.groupA
		else:
			raise ValueError("group not in contract")

class Group(object):
	'''
	a group
	'''
	
	def __init__(self,name):
		self.name = name
		self.contracts = set()
		self.maxNum = None
		self.minNum = None
		self.prototypes = dict()
		
	def __repr__(self):
		textMax = ', max:{0}'.format(self.maxNum) if self.maxNum != None else ''
		textMin = ', min:{0}'.format(self.minNum) if self.minNum != None else ''
		return 'group({0}{1}{2})'.format(self.name,textMax, textMin)
		
	# Placement
			
	def setMax(self, newMax):
		self.maxNum = newMax
			
	def setMin(self, newMin):
		self.minNum = newMin
	
	def addContract(self, contract):
		self.contracts.add(contract)
		
	def hasContracts(self):
		return len(self.contracts) > 0
	
	def clearContracts(self):
		self.contracts = set()
	
	def getBound(self, setOfBound):
		if self not in setOfBound:
			setOfBound.add(self)
			for contract in self.contracts:
				if contract.isBound():
					contract.otherGroup(self).getBound(setOfBound)
				
	def getGroupsWithContract(self, setOfGroups):
		if self not in setOfGroups:
			setOfGroups.add(self)
			for contract in self.contracts:
				contract.otherGroup(self).getGroupsWithContract(setOfGroups)
	
	# Rucksack problem

	def setMembersCount(self, count):
		self.count = count
	
	def getMin(self):
		minNum = self.minNum
		if minNum == None:
			minNum = 1
		if minNum > self.count:
			raise ValueError("not enough remaining")
		else:
			return minNum
	
	def getMax(self):
		maxNum = self.maxNum 
		if maxNum == None:
			maxNum = self.count
		return min(maxNum, self.count)
	
	def addPrototype(self, prototype):
		self.prototypes[prototype.cpuArch] = prototype
	
	def getPrototype(self, cpuArch):
		if cpuArch in self.prototypes:
			return self.prototypes[cpuArch]
		else:
			raise ValueError("no prototype for cpuArch:{0}".format(cpuArch))

class Prototype(object):
	''' 
	a prototype
	'''
	
	def __init__(self, cpuArch, reqDisc, reqRAM):
		self.cpuArch = cpuArch
		self.reqDisc = reqDisc
		self.reqRAM = reqRAM

class Host(object):
	'''
	a host
	'''

	ARCH_32 = '32 bit'
	ARCH_64 = '64 bit'
	
	def __repr__(self):
		return 'host({0},{1}/{2}, ram:{3}, hd:{4})'.format(self.cpuArch, self.bookedMembers, self.maxMembers, self.availableRAM, self.freeDisc)
		
	def __init__(self, maxMembers, cpuArch, freeDisc, availableRAM, rankingPoints):
		self.maxMembers = maxMembers
		self.cpuArch = cpuArch
		self.freeDisc = freeDisc
		self.availableRAM = availableRAM
		self.rankingPoints = rankingPoints
		
		self.bookings = []
		self.bookedMembers = 0
	
	def acceptBooking(self, booking):	
		hd = 0
		ram = 0
		cnt = 0
		for (group, amount) in booking.order.items():
			try:
				prototype = group.getPrototype(self.cpuArch)
			except ValueError:
				# no prototype for arch
				return False
			hd += amount * prototype.reqDisc
			ram += amount * prototype.reqRAM
			cnt += amount
		if (self.bookedMembers + cnt) <= self.maxMembers and hd <= self.freeDisc and ram <= self.availableRAM:
			return True
		else:
			return False
	
	def applyBooking(self, booking):
		self.bookings.append(booking)
		booking.bindHost(self)
		for (group, amount) in booking.order.items():
			prototype = group.getPrototype(self.cpuArch)
			self.freeDisc -= amount * prototype.reqDisc
			self.availableRAM -= amount * prototype.reqRAM
			self.bookedMembers += amount
		assert(self.freeDisc >= 0)
		assert(self.availableRAM >= 0)
		assert(self.bookedMembers <= self.maxMembers)
	
	def removeBooking(self, booking):
		assert(booking in self.bookings)
		for (group, amount) in booking.order.items():
			prototype = group.getPrototype(self.cpuArch)
			self.freeDisc += amount * prototype.reqDisc
			self.availableRAM += amount * prototype.reqRAM
			self.bookedMembers -= amount
		booking.host = None
		self.bookings.remove(booking)

class HostPattern(object):
	'''
	a host pattern
	contains: groups and contracts
	'''

	def __init__(self, groups, groupedHostPatternID):
		self.groups = set(groups)
		self.groupedHostPatternID = groupedHostPatternID

	def __repr__(self):
		return 'pattern(#{0},{1})'.format(self.groupedHostPatternID,self.groups)
		
	def getMinSize(self):
		return sum([group.getMin() for group in self.groups])
	
	def getRemainingCount(self):
		return sum([group.count for group in self.groups])
	
	def getMaxSize(self):
		return sum([group.getMax() for group in self.groups])
	
	def hasContracts(self):
		for group in self.groups:
			if group.hasContracts():
				return True
		return False

class Booking(object):
	'''
	a host-pattern booking
	'''
	
	def __repr__(self):
		return 'booking({0})'.format(','.join(['{0} from {1}'.format(c,h.name) for (h,c) in self.order.items()]))
	
	
	
	def __init__(self, pattern):
		self.pattern = pattern	
		self.host = None
		
		self.order = dict()
		for group in self.pattern.groups:
			self.order[group] = 0
			
	def removeBooking(self):
		if self.host != None:
			self.host.removeBooking(self)
		for group in self.pattern.groups:
			group.count += self.order[group]
			self.order[group] = 0
		self.host = None		
		
	def revertSplit(self, splitted):
		for g in splitted.pattern.groups:
			self.changeAmount(g, splitted.order[g])
			splitted.changeAmount(g, -splitted.order[g])
		
	def splitBooking(self, onlyCheck=False):
		newOrdnerA = dict()
		newOrdnerB = dict()
		fail = False
		for group in self.pattern.groups:
			minN = 1
			if group.minNum != None:
				minN = group.minNum
			if self.order[group] >= (2*minN):
				old = self.order[group]
				newOrdnerA[group] = int(old / 2)
				newOrdnerB[group] = old - newOrdnerA[group]
				assert(old==newOrdnerA[group]+newOrdnerB[group])
				assert(minN<=newOrdnerA[group])
				assert(minN<=newOrdnerB[group])
			else:
				fail = True
		if fail:
			if onlyCheck:
				return False
			else:
				raise ValueError()
		elif onlyCheck:
			return True
		else:
			newBooking = Booking(self.pattern)
			for group in self.pattern.groups:
				self.changeAmount(group, newOrdnerA[group]-self.order[group])
				newBooking.bookGroup(group, newOrdnerB[group])
			return newBooking		
		
	def bindHost(self, host):
		assert(self.host == None)
		self.host = host
	
	def bookGroup(self, group, targetAmount):
		assert(self.order[group]==0)
		assert(targetAmount>0)
		self.changeAmount(group, max(group.getMin(), min(group.getMax(), targetAmount)))
	
	def changeAmount(self, group, amountDiff):
		group.count -= amountDiff
		self.order[group] += amountDiff
		if self.host != None:
			prototype = group.getPrototype(self.host.cpuArch)
			self.host.freeDisc -= prototype.reqDisc * amountDiff
			self.host.availableRAM -= prototype.reqRAM * amountDiff
			self.host.bookedMembers += amountDiff
		
class Container(object):
	'''
	a container
	contains: a list of group-amount 
	'''

	def __init__(self):
		self.groups = set()
		
	def __eq__(self, other):
		return self.groups == other.groups 
	
	def __hash__(self):
		return 0
	
	# Placement
		
	def containsOtherContainer(self, container):
		return container.groups <= self.groups
		
	'''
	build discontiguous sets of groups
	'''
	def splitted(self):
		result = []
		groups = set(self.groups)
		while len(groups) > 0:
			nextGroup = groups.pop()
			nextSet = set()
			nextGroup.getBound(nextSet)
			result.append(nextSet)
			groups = groups - nextSet
		return result
	
	def addGroup(self, group):
		self.groups.add(group)
	
	def addGroups(self, groups):
		for group in groups:
			self.addGroup(group)
	
	'''
	build a new container with groups, not connected with listOfGroups
	'''
	def split(self, listOfGroups):
		newContainer = Container()
		bound = set()
		for group in listOfGroups:
			group.getBound(bound)
		newGroups = self.groups - bound
		for group in newGroups:
			newContainer.addGroup(group)
		return newContainer
	
	def containsGroup(self, group):
		return group in self.groups
	
	def checkAcceptance(self, contract, group):
		conflict = set()
		
		if contract.isExclusion():
			for otherGroup in self.groups:
				if contract.matchGroup(otherGroup):
					conflict.add(otherGroup)
		
		if len(conflict) > 0:
			return (False, conflict)
		else:
			return (True, set())
			
class GroupRelationsProcessing(object):
	'''
	process group relations, build patterns, check for conflicts
	'''

	def __init__(self, groups, contracts):

		self.containers = []	
		self.groups = set(groups)
		self.contracts = set(contracts)

		for contract in self.contracts:
			#print(contract)
			pass
		
		
		
	
	def processGroups(self):
		'''
		process all groups
		
		self.containers = list of sets of container
		a host can be build from all patterns from all sets, but from each set only one container
		'''
		# group groups by conntected contracts
		todo = set(self.groups)
		while len(todo) > 0:
			item = todo.pop()
			items = set()
			item.getGroupsWithContract(items)
			todo = todo - items
			# items = groups grouped by conntected contracts
			# build list of bounded groups
			groups = []
			while len(items) > 0:
				item = items.pop()
				l = set()
				item.getBound(l)		
				items = items - l
				groups.append(l)
				# check inner-bound-group conflict
				self.checkGroupsConflict(l)
					
				
				
			# groups = list of bounded groups
			
			container = set([Container()])
			for l in groups:
				self.process(groups=l, containers=container)
			
			# check container against subsets
			finalContainers = set()
			for ct in container:
				isSubset = False
				for ctOther in container:
					if ct != ctOther:
						if ctOther.containsOtherContainer(ct):
							isSubset = True
							break
				if not isSubset:
					finalContainers.add(ct)
			
			self.containers.append(finalContainers)
			
			
	def process(self, groups, containers):
		'''
		process given groups
		'''
		newContainers = set()
		for container in containers:
			conflict = set()
			acceptance = True
			for group in groups:
				for contract in group.contracts:
					check = container.checkAcceptance(contract, group)
					if not check[0]:
						acceptance = False
						conflict = conflict | check[1]
					
			if acceptance:
				container.addGroups(groups)
			else:
				split = container.split(conflict)
				split.addGroups(groups)
				newContainers.add(split)
			
		for newContainer in newContainers:
			containers.add(newContainer)
			
	def checkGroupsConflict(self, groups):
		'''
		check relation conflicts
		'''
		cp = set(groups)
		while len(cp) > 0:
			item = cp.pop()
			for contract in item.contracts:
				if contract.isExclusion():
					if contract.otherGroup(item) in cp:
						raise ValueError("groups bound, but also has exclusion: {0}, {1}".format(item, contract.otherGroup(item)))
			
	
	
	
	def getHostPatterns(self):
		'''
		returns a list of lists of groupSets
		[ [{,,},{,,}] ]
		a inner list represents all possible patterns of a unique host
		'''
		result = []
		for containerList in self.containers:
			l = []
			for container in containerList:
				l.append(container.splitted())
			result.append(l)
		return result		
	
	def getPatternManager(self):
		'''
		returns the pattern manager
		'''
		groups = self.groups
		patterns = self.getHostPatterns()
		patternManager = HostPatternManager(patterns, groups)
		return patternManager
		
	def getHostPatternsHumanReadable(self):
		'''
		print human readable version
		'''
		patterns = self.getHostPatterns()
		print('{0} different pattern groups:'.format(len(patterns)))
		for index, patternGroup in enumerate(patterns):
			print('\tpg{0}:'.format(index,patternGroup))
			start = ord("a")
			for pgi,pg in enumerate(patternGroup):
				print('\t\t{0}: {1}'.format(chr(start+pgi), repr(pg)))


class HostPatternManager(object):
	'''
	process patterns-hosts, build list of bookings
	'''
	
	STRATEGY_USE_AS_LESS_AS_POSSIBLE = 'minimum'
	STRATEGY_USE_AS_MANY_AS_POSSIBLE = 'almostAll'
	
	def placement(self, hosts, strategy, resetOnFailure=False):
		'''
		placement with given hosts
		'''
	
		# config
		finalBookings = []
		groups = list(self.groups.keys())
		if HostPatternManager.STRATEGY_USE_AS_LESS_AS_POSSIBLE != strategy and HostPatternManager.STRATEGY_USE_AS_MANY_AS_POSSIBLE != strategy:
			raise ValueError("unkown strategy")
		
		# sort hosts
		tmp = dict()
		tmp[Host.ARCH_32] = []
		tmp[Host.ARCH_64] = []
		unusedHosts = set()
		for (cpuArch, hostList) in tmp.items():
			for host in hosts:
				if host.cpuArch == cpuArch:
					hostList.append(host)
					unusedHosts.add(host)
			tmp[cpuArch] = sorted(hostList, key=lambda host: host.rankingPoints, reverse=True)
		hosts = tmp
		#print(hosts)
		
		
		# sort patterns
		patternListNoConflicts = []
		patternListWithConflicts = []
		
		for patternGroup in self.patternGroups:
			if len(patternGroup) == 1:
				for pattern in patternGroup:
					hasContracts = False
					for p in self.patternLists[pattern]:
						if p.hasContracts():
							hasContracts = True
							break
					if hasContracts:
						patternListWithConflicts.append([self.patternLists[pattern]])
					else:
						patternListNoConflicts.append(self.patternLists[pattern])
			else:
				patternListWithConflicts.append([self.patternLists[pID] for pID in patternGroup])
		
		def bookingGen(pattern, fullGroups):
			fullGroups = list(fullGroups)
			minBookings = 0
			groupSize = dict()
			for g in fullGroups:
				minBookings = max(minBookings, math.ceil(g.count / g.getMax()))
				groupSize[g] = g.count
			assert(minBookings>0)
			bookings = []
			for i in range(0,int(minBookings)):
				booking = Booking(pattern)
				for g in fullGroups:
					if g.count > 0:
						booking.bookGroup(g, math.ceil(groupSize[g]/minBookings))
				bookings.append(booking)
			while len(fullGroups) > 0:
				g = fullGroups.pop()
				while g.count > 0:
					random.choice(bookings).incGroupAmount(g)
			return bookings
		
		def findHost(booking):
			found = None
			for hostArchList in hosts.values():
				for h in hostArchList:
					# check host ressources
					if h.acceptBooking(booking):
						# check host booking
						otherTest = True
						for otherBooking in h.bookings:
							otherTest = self.checkPatternCompatibility(otherBooking.pattern, booking.pattern)
							if not otherTest:
								break
						if otherTest:
							if HostPatternManager.STRATEGY_USE_AS_MANY_AS_POSSIBLE == strategy:
								if h.bookedMembers > 0:
									if found == None or found.bookedMembers > h.bookedMembers:
										found = h
								else:
									return h
							else:
								return h
			return found
			 
		# process all pattern
		if len(patternListWithConflicts) == 0:
			while len(patternListNoConflicts) > 0:
				patternListWithConflicts.append([patternListNoConflicts.pop()])
		while len(patternListWithConflicts) > 0:
			patternList = patternListWithConflicts.pop()
			#print(patternList)
			# calc imp
			imp = dict()
			seenGroups = dict()
			for patterns in patternList:
				for pattern in patterns:
					for g in pattern.groups:
						if g not in seenGroups:
							seenGroups[g] = 0
						seenGroups[g] += 1
					imp[pattern.groupedHostPatternID] = 0
			for patterns in patternList:
				for pattern in patterns:
					value = 0
					for g in pattern.groups:
						if seenGroups[g] == 1:
							value += 1
						else:
							value += 1 / len(seenGroups)
					imp[pattern.groupedHostPatternID] += value
					
			patternIDs = list(imp.keys())
			patternIDs = sorted(patternIDs, key=lambda pID: imp[pID], reverse=True)
			
			# for all patternLists
			for patternID in patternIDs:
				# sort patterns
				patterns = sorted(self.patternLists[patternID], key=lambda x: len(x.groups), reverse=True)
				for pattern in patterns:
					# check if pattern is last of group x
					lastGroup = []
					for g in pattern.groups:
						if seenGroups[g] == 1:
							lastGroup.append(g)
						seenGroups[g] -= 1
					# is last?, so choose
					if len(lastGroup) > 0:
						patternBookings = bookingGen(pattern, fullGroups=lastGroup)
						# choose hosts
						while len(patternBookings) > 0:
							booking = patternBookings.pop(0)
							host = findHost(booking)
							if host == None:
								log.info("\tsplit booking: {0}".format(booking))
								try:
									split = booking.splitBooking()
									patternBookings.append(split)
									patternBookings.append(booking)
								except ValueError:
									msg = "unused hosts: {0}".format(len(unusedHosts))
									
									for hostArchList in hosts.values():
										for h in hostArchList:
											msg = msg + "\n\t{0}/{1}: {2}".format(h.bookedMembers,h.maxMembers,h)
									
									# reset bookings
									if resetOnFailure:
										booking.removeBooking()
										for booking in patternBookings:
											booking.removeBooking()
											del(booking)
										for booking in finalBookings:
											booking.removeBooking()
											del(booking)
											
									# abort placement
									raise ValueError("cant find valid assignment\n{0}".format(msg))	
							else:
								log.info("\tapplyBooking: {0}".format(booking))
								host.applyBooking(booking)
								finalBookings.append(booking)
								if host in unusedHosts:
									unusedHosts.remove(host)
			if len(patternListWithConflicts) == 0:
				while len(patternListNoConflicts) > 0:
					patternListWithConflicts.append([patternListNoConflicts.pop()])

		# use more hosts?
		if strategy == HostPatternManager.STRATEGY_USE_AS_MANY_AS_POSSIBLE:
			#print("distribute bookings")
			sortedBookings = sorted(finalBookings, reverse=True, key=lambda x: sum(x.order.values()))
			while len(unusedHosts) > 0 and len(sortedBookings) > 0:
				booking = sortedBookings.pop(0)
				checkSplitted = True
				splittedList = []
				while checkSplitted:
					try:
						splitted = booking.splitBooking()
						splittedList.append(splitted)
						# find other host
						foundHost = None

						sortedUnusedHosts = sorted(unusedHosts, key=lambda host: host.rankingPoints, reverse=True)

						for otherHost in sortedUnusedHosts:
							if otherHost.acceptBooking(splitted):
								foundHost = otherHost
								break
						if foundHost == None:
							# next split, retry host search
							continue
						else:
							# revert change from original
							splittedList.pop()
							for unusedSplitted in splittedList:
								booking.revertSplit(unusedSplitted)
							# update lists 
							foundHost.applyBooking(splitted)
							unusedHosts.remove(foundHost)
							sortedBookings.append(splitted)
							sortedBookings.append(booking)
							finalBookings.append(splitted)
							# resort
							sortedBookings = sorted(sortedBookings, reverse=True, key=lambda x: sum(x.order.values()))	
							checkSplitted = False
					except ValueError:
						checkSplitted = False
						# revert split
						for unusedSplitted in splittedList:
							booking.revertSplit(unusedSplitted)
				


	'''
	calculation stuff
	'''
	def __init__(self, listOfPatterns, listOfGroups):	
		self.groups = dict()
		for group in listOfGroups:
			self.groups[group] = []
			
		self.patternLists = dict()
		self.patternGroups = []
		 
		patternGroupsID = 0			
		for patternGroup in listOfPatterns:
			setOfGroupIDs = set()
			self.patternGroups.append(setOfGroupIDs)
			for patternList in patternGroup:
				groupedHostPattern = []
			
				patternGroupsID += 1
				self.patternLists[patternGroupsID] = groupedHostPattern
				setOfGroupIDs.add(patternGroupsID)
				for pattern in patternList:
					hostPattern = HostPattern(pattern, patternGroupsID)
					groupedHostPattern.append(hostPattern)
					for group in hostPattern.groups:
						self.groups[group].append(hostPattern)
	
	def getPatternsForGroup(self, group):
		return self.groups[group]
		
	def getOptionalPatterns(self, pattern):
		return self.patternLists[pattern.groupedHostPatternID]
	
	def getOtherPatterngroups(self, pattern):
		result = set()
		for patternGroup in self.patternGroups:
			if pattern.groupedHostPatternID not in patternGroup:
				result = result | patternGroup
		return result
	
	def checkPatternCompatibility(self, patternA, patternB):
		if patternA.groupedHostPatternID == patternB.groupedHostPatternID:
			# check whether pattern has "max" contracts
			if patternA == patternB:
				for group in patternA.groups:
					if group.maxNum != None:
						return False
				return True						
			else:
				return True		
		if patternA.groupedHostPatternID in self.getOtherPatterngroups(patternB):
			return True	
		return False