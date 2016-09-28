# -*- coding: utf-8 -*-
"""
Spyder Editor

This temporary script file is located here:
/home/erick/.spyder2/.temp.py
"""

import gambit

g = gambit.Game.new_tree()

p1 = g.players.add("Radiant")
p2 = g.players.add("Dire")
print g.players
g.root.append_move(p1, 8)
counter = 0
available = range(8)
print "aaa", g.players[0].strategies
for node in g.root.children:
    node.label = "Radiant ban hero "+str(available[counter])
    available1 = available[:]
    available1.remove(available1[counter])
    #print available
    #print available1
    counter = counter + 1
    node.append_move(p2, 7)
    #print "bbb", g.players[1].strategies
    counter2 = 0
    for node2 in node.children:
        node2.label = "Dire ban hero "+str(available1[counter2])
        available2 = available1[:]
        available2.remove(available2[counter2])
        #print available2
        counter2 = counter2 + 1
        node2.append_move(p1, 6)
        #print "ccc", g.players[0].strategies
        counter3 = 0
        for node3 in node2.children:
            node3.label = "Radiant ban hero "+str(available2[counter3])
            #print node3.label
            available3 = available2[:]
            available3.remove(available3[counter3])
            counter3 = counter3 + 1
            node3.append_move(p2, 5)
            #print "ddd", g.players[1].strategies
            counter4 = 0
            for node4 in node3.children:
                node4.label = "Dire ban hero "+str(available3[counter4])
                available4 = available3[:]
                available4.remove(available4[counter4])
                counter4 = counter4 + 1
                pay1 = available4[0]+available4[3]
                pay2 = available4[1]+available4[2]
                g.outcomes.add([pay1,pay2])
                node4.outcome = g.outcomes[len(g.outcomes)-1]
                print node4.outcome
    s=gambit.nash.ExternalLCPSolver()
    s.solve(g)
            

