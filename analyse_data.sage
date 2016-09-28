import csv
import matplotlib.pyplot as plt
import numpy as np

hero_names=[" Bloodseeker " ,
" Ancient Apparition " ,
" Nyx Assassin " ,
" Earthshaker " ,
" Abaddon " ,
" Morphling " ,
" Anti-Mage " ,
" Invoker " ,
" Slark " ,
" Puck " ,
" Skywrath Mage " ,
" Dazzle " ,
" Sniper " ,
" Dragon Knight " ,
" Weaver " ,
" Shadow Shaman " ,
" Bane " ,
" Tiny " ,
" Arc Warden " ,
" Lone Druid " ,
" Riki " ,
" Lion " ,
" Terrorblade " ,
" Rubick " ,
" Visage " ,
" Clinkz " ,
" Nature's Prophet " ,
" Pugna " ,
" Alchemist " ,
" Spirit Breaker " ,
" Ember Spirit " ,
" Jakiro " ,
" Lich " ,
" Lina " ,
" Viper " ,
" Kunkka " ,
" Beastmaster " ,
" Shadow Demon " ,
" Necrophos " ,
" Winter Wyvern " ,
" Slardar " ,
" Disruptor " ,
" Queen of Pain " ,
" Chaos Knight " ,
" Mirana " ,
" Warlock " ,
" Legion Commander " ,
" Meepo " ,
" Templar Assassin " ,
" Enchantress " ,
" Drow Ranger " ,
" Crystal Maiden " ,
" Chen " ,
" Omniknight " ,
" Shadow Fiend " ,
" Earth Spirit " ,
" Juggernaut " ,
" Enigma " ,
" Io " ,
" Phantom Assassin " ,
" Sven " ,
" Phoenix " ,
" Undying " ,
" Dark Seer " ,
" Naga Siren " ,
" Witch Doctor " ,
" Lifestealer " ,
" Keeper of the Light " ,
" Medusa " ,
" Huskar " ,
" Wraith King " ,
" Batrider " ,
" Pudge " ,
" Razor " ,
" Troll Warlord " ,
" Lycan " ,
" Centaur Warrunner " ,
" Windranger " ,
" Sand King " ,
" Tidehunter " ,
" Storm Spirit " ,
" Axe " ,
" Tusk " ,
" Magnus " ,
" Outworld Devourer " ,
" Spectre " ,
" Ogre Magi " ,
" Phantom Lancer " ,
" Night Stalker " ,
" Gyrocopter " ,
" Silencer " ,
" Timbersaw " ,
" Elder Titan " ,
" Techies " ,
" Bounty Hunter " ,
" Faceless Void " ,
" Leshrac " ,
" Venomancer " ,
" Ursa " ,
" Oracle " ,
" Luna " ,
" Bristleback " ,
" Broodmother " ,
" Doom " ,
" Death Prophet " ,
" Treant Protector " ,
" Clockwerk " ,
" Zeus " ,
" Vengeful Spirit " ,
" Tinker " ,
" Brewmaster "]



def build_game(row_player_file):
    """Import the bi matrices and create the game object"""
    bi_matrices = []
    fle=row_player_file
    f = open(fle, 'r')
    csvrdr = csv.reader(f)
    bi_matrices.append(matrix([[float(ele) for ele in row] for row in csvrdr]))
    f.close()
    bi_matrices.append(-1*bi_matrices[0])
    return NormalFormGame(bi_matrices)

g=build_game("/home/erick/Dropbox/erick/dotaproj/postpycon/advantages_subset.csv")
m = g.payoff_matrices()[0].n(digits=2)
sum_of_threats = [sum([row[k] for row in m])  for k in range(20)]
print [hero_names[i] for i, score in enumerate(sum_of_threats) if score == min(sum_of_threats)]
#plot(g.payoff_matrices()[0], colorbar=True,cmap='hsv')


def get_best_response_dictionary(game):
    """Returns the best response dictionary for a given player"""
    N = len(hero_names)
    best_response_dictionary = {}
    for i in range(1, N + 1):
        strategy = [0 for k in range(i - 1)] + [1] + [0 for k in range(N - i)]
        hero = hero_names[i - 1]
        best_responses = [hero_names[br] for br in g.best_responses(strategy,0)]
        best_response_dictionary[hero] = best_responses
    return best_response_dictionary
    
#d = get_best_response_dictionary(g)
#for hero in d:
#    print hero +": " 
#    for br in d[hero]:
#        print "\t", br
        
        
def digraph_representation(game):
    """Get a graphical representation of the best response dynamics"""
    G = DiGraph(get_best_response_dictionary(game))
    return G
        
#G = digraph_representation(g)
#G.show(layout='circular',figsize=[12,12])

#NEs = g.obtain_nash(algorithm='lrs')
#print len(NEs)
#print NEs


def analyse_set_of_NE(NEs):
    """Go through the NEs and analyse"""
    
    return [sum([vector(ne[player])/len(NEs) for ne in NEs]) for player in [0, 1]]  
    
def plot_mean_NE(game, output_file, title=None):
    """Obtain the plot of the mean NE for a game: save to a file given by `output_file` also return the mean ne"""
    mean_ne = analyse_set_of_NE(NEs)

    N = len(hero_names)
    p1 = mean_ne[0]
    p2 = mean_ne[1]


    heroes = range(N)  # the x locations for the heroes
    width = 0.35       # the width of the bars

    fig, ax = plt.subplots()
    rects1 = ax.bar(heroes, p1, width, color='black')
    rects2 = ax.bar([h + width for h in heroes], p2, width, color='grey')

    # add some text for labels, title and axes ticks
    ax.set_ylabel('Probability')
    if title:
        ax.set_title(title)
    else:
        ax.set_title('Mean probability for both players accross all equilibria')
    ax.set_xticks([h + width for h in heroes])
    ax.set_xticklabels(hero_names, rotation='vertical')
    plt.savefig(output_file, bbox_inches='tight')
    return mean_ne
    
    
#mean_ne = plot_mean_NE(g, "risk-averse-plot-ne-all.svg", "Risk Averse - All guides")

def heroes_that_are_played(mean_ne):
    return [hero_names[i] for i in range(len(hero_names)) if mean_ne[0][i] !=0]
def heroes_that_are_not_played(mean_ne):
    return [hero_names[i] for i in range(len(hero_names)) if mean_ne[0][i] ==0]
    
#played = heroes_that_are_played(mean_ne)
#print played


#not_played = heroes_that_are_not_played(mean_ne)
#print not_played


#p = G.plot(layout='circular', vertex_colors={(0,.75,1):played, (1,.05,0):not_played}, title="Risk Averse - All guides")
#p.save("risk-averse-plot-br-all.svg")
