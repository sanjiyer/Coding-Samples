'''
Candidate number: 26910

MA214 Assessed Coursework 2024
'''

from collections import deque
from math import inf

'''
Explain your program design here (see Task 5).

Designing this programme,I aimed to choose the data structures and algorithms which were most suited to the task,
and assessing trade offs between time, memory and feasability of implementation.

Starting with the constructor and add_line function for the SubmarineNetwork class, I stored the 
new lines in two ways: as a list with dictionaries, and an ajacency list.
I used a list to store the new lines, and a dictionary data structure to store the line_id 
and stop for each new line added to the list. I used this primarily for easy implementation
of the lines_stopping_at function, and best_direct_connection function, allowing for very simple 
and straightforward implementation for lookup.

I also created an adjacency list for the new lines, in anticipation of requiring it for the modified
of Dijkstra's algorithm for the next_fastest_connection algorithm. I chose to use an ajacency list as
opposed to an ajacency matrix as the ajacency list is more memory efficient when representing sparse graphs,
where the number of edges (connections) are significanly less than the vertices (stops) squared.
This is ideal for the data used here: which is lines and stops along those lines.  

For the lines_stopping_at function, I used the list of lines added to look through the stops and create a 
schedule for each lines. To sort the pairs by time I opted to use a merge sort algorithm. I used merge sort by 
a process of elimination. Compared to bubble sort and insertion sort with running times of O(n^2), I narrowed it
down to merge sort or quick sort. Both best case running times were O(nlogn). Though merge sort requires extra 
memory, quick sort's worst case running time is just as bad as insertion: O(n^2), and merge sort is stable. In 
this trade off I opted to sacrifice memory efficicicy in favour of a better worst case running time, considering 
the expected characteristics of the data set to not be very large, as there likely limited lines and stops in a 
submarine network due to resource constraints.

For my implementation of best_direcct_connection, I utilised my list of lines, and performed linear search throughout 
the lines, the stops of each line and the stops of the line of each origin terminal. I understand that my implementation 
has quite a high running time of O(l*s^2), with l=lines and s=average stops per line. The linear search is optimal for a 
small number of stops in each line, which I assumed to be true considering the expected characteristic of the submarine 
network. The linear search becomes very inefficienct for a large number of stops in each line. I could have opted for a 
different approach such as constructing an adjacency list where is each entry represented the earliest connection between 
two terminals, and then the function could lookup from this adjacency list - this requires extra memory but would reduce 
running time. I attempted this method however the implementation proved to be quite difficult , and was compromising on 
the correctness of my algorithm. Due to the small scale of the data set, I opted to stick with the linear search, and for 
ease of my own implementation.


When deciding how to represent the vertex attributes in next_fastest_connection I had two choices. I could either represent
the vertex attributes in additional arrays parallel the adjacency list. However I chose to represent the vertex attributes 
as instance variables within a sublass of a vertex class, to take advantage of the simplicity of implementation and the use 
of an object-oriented language like python. 

In my implementation of the actual function, I initialised a dictionary vertices where keys are terminal names and values are 
instances of the Vertex class, to create a vertex for each terminal in the network. After inititalising a deque queue to perform 
BFS, I began the loop to dequeue a vertex from the queueand get it's name. Then I perfomed Dijkstra's algorithm, which I modified 
from the moodle and some online resources cited below, to adapt it to the network in the best way I could. This is followed by a 
path list being created, which recontructs the shortest path, reversing it to get it in the right order, and outputs 
the path in the required format. I implemented an auxiliary function max, as to not use the built in python function. 

I am aware that my output for the next_fastest_connection function does not match the desired output with the testing code. 
The key errors are that the origin terminal does not correctly display the departure time or the line taken, and the destination 
is printed twice (as I appended it to have None as the line_id). Moreover the very times and lines don't match the desired output.
origin_departure_time = time + 1
the above line sets the departure time at the origin to 1 after the time asked or, which I am aware is incorrect but
is there as a place holder such that the algorithm does not display infinity instead. 
I have tried debugging my program for a long time in order to achieve the desired output but I have unfortunately 
not been able to given the time restrictions. 
Given more time, I would debug further to identify the issues in my code, and understand where I have missed assigning
the correct departure time to my origin_departure_time, and why the first diplay of my destination does not output 'None' as 
the line_id. This in addition to figuring out why my code does not match the expected departure times, and what my traversal 
is doing wrong.

'''

#best direct has high running time, but trade off with implementation complexity. 
#ajacency list used for dijkstra




class SubmarineNetwork:
    # A class for storing the submarine network and obtaining information about connections.
                
    def __init__(self):
        
        self.lines = []
        #list to store sub lines
        self.line_id_counter = 0
        self.adjacency_list = {} 
        #initialising an empty ajacency list to store connections
        
    '''    
    running time: O(n)
        
    The assignments outside and within the loop are constant time operations: O(1). We now look at the for loop which 
    iterates over each pair of consecutive stops in the stops list (excluding the last). Letting the number of 
    stops be deonted by n, we can say that the for loop must iterate n-1 times.Therefore we can conclude that 
    the loop has linear time complexity O(n), and the add_line function has running time O(n).
    
    '''
    def add_line(self, stops): 
        #stops are paired entries (name, time)
        
        line_id = len(self.lines)  
        #assign next available line id based on the number of existing lines

        new_line = {'line_id': line_id, 'stops': stops}
        #created dictionary contraining 2 key-value pairs: line id and stops. this lets us store the schedule of stops for the new line.
        
        self.lines.append(new_line)
        #added new_line dictionary to the self.lines list.
        self.line_id_counter +=1
        
        for i in range(len(stops) - 1):
        #iterates over each pair of consecutive stops in the stops list, excluding the last stop
            origin, departure_time = stops[i]
            #assigns name of currect stop as origin, and time as departure time
            destination, arrival_time = stops[i + 1]
            #assigns name of subsequent stop as destinaton, and time as arriving time
             
            
            if origin not in self.adjacency_list:
                self.adjacency_list[origin] = []
            #if destination not in self.adjacency_list:
              #  self.adjacency_list[destination] = []
            #initialise an empty list if origin or destination isn't in an existing list
                
            self.adjacency_list[origin].append((destination, departure_time, arrival_time, line_id))
            #adds new edges to the adjacency list representation of the network. For each origin, adds a tupe with infor about the destination, and departure and arrival times 
            #adjacency list representation of the submarine network, where each terminal serves as a vertex, and each stop serves as an edge between terminals with associated departure and arrival times.
    
    '''
    running time: O(ls + nlogn)
    
    Let l = the number of lines, s = the average number of stops/line, n = number of tuples in schedule list.
    First looking at the outer loop which iterates through each submarine line (O(l)), and the inner loop 
    that iterates over the stops in each line (O(s)), the loops have a time complexity of O(ls).
    The if condition and appending each have constant time O(1). 
    Then using the standard running time of the merge sort, due to the dividing
    taking O(logn) time and the merging taking O(n), we get O(nlogn).  
    Overall time complexity is therefore O(ls + nlogn)

    '''
    def lines_stopping_at(self, terminal_name, start_time, end_time):
        # Returns a list of pairs (id,time) of lines stopping at the given terminal in the given time interval, ordered by time.
        def merge_sort(arr):
            if len(arr) <= 1:
                return arr
            
            mid = len(arr) // 2
            left_half = arr[:mid]
            right_half = arr[mid:]
            
            left_half = merge_sort(left_half)
            right_half = merge_sort(right_half)
            
            return merge(left_half, right_half)
    
        def merge(left, right):
            result = []
            i = j = 0
            
            while i < len(left) and j < len(right):
                if left[i][1] <= right[j][1]:
                    result.append(left[i])
                    i += 1
                else:
                    result.append(right[j])
                    j += 1
            
            while i < len(left):
                result.append(left[i])
                i += 1
            
            while j < len(right):
                result.append(right[j])
                j += 1
        
            return result
            
        schedule = []
        #initialise empty list
        
        for line in self.lines:
            for stop_name, stop_time in line['stops']:
                if stop_name == terminal_name and start_time <= stop_time <= end_time:
                    #iterate through each submarine line and check if the stop matches the terminal and time falls in range. 
                    
                    schedule.append((line['line_id'], stop_time))
                    #appends tuple to schedule with line ID and stop time
        
        return merge_sort(schedule)
        #returns list with tuples

        
    '''
    running time: O(l*s^2) 
        
    The if conditions and assignments are constant time O(1).
    The nested for loops interate through the lines (l), and the stops for each line (s). 
    Within each iteration we again check whether the destination terminal is reachable from the 
    origin terminal on each line, which in the worst case means iterating through all the stops
    in a line. So the time complecity of the function is O(l*s^2).
    
    
    '''
    def best_direct_connection(self, origin, destination, time):

        # Check if origin and destination terminals are in the adjacency list
        if origin not in self.adjacency_list or destination not in self.adjacency_list:
            return None
        
        earliest_connection = None
        
        # Iterate through each submarine line
        for line in self.lines:
            # Iterate through stops of the current line
            for i in range(len(line['stops']) - 1):
                # Check if the origin terminal is a stop on the current line
                if line['stops'][i][0] == origin:
                    # Check if the destination terminal is reachable from there
                    for j in range(i + 1, len(line['stops'])):
                        dest, departure_time = line['stops'][j]
                        # Check if the destination matches and departure time is after the given time
                        if dest == destination and departure_time >= time:
                            # Check if this connection is earlier than the current earliest connection
                            if earliest_connection is None or departure_time < earliest_connection[2]:
                                # Store the line ID, departure time, and arrival time as the earliest connection
                                earliest_connection = (line['line_id'], line['stops'][i][1], departure_time)
                                break  # Found earliest connection, no need to continue searching for this line
        
        return earliest_connection
  
    '''
    running time: O(V+E)
    
    Let V be the number of vertices, i.e. terminals, and E be the number the edges i.e. connection between the 
    terminals in the network.
    The running time of Dijkstra's algorithm here, since we use deque instead of min heap, is not O(V+E)*log(V). Instead
    it is using the BFS strategy, which has a slightly worse run time of O(V+E).
    Reconstructing the shortest path involves traversing from the destination vertex back to the origin vertex,
    which takes O(V+E) time. The reversal of the path takes O(V) time. The initialisiations take constant time O(1).
    Therefore Dijkstra's algorithm dominates and the overall running time is O(V+E).
    
    '''
    def max(a, b):
        if a > b:
            return a
        else:
            return b

    def next_fastest_connection(self, origin, destination, time):
        #nested class to represent the vertices and their attributes in Dijkstra's algo.
        class Vertex:
            def __init__(self, name):
                self.name = name
                self.d = float('inf')  # Distance
                self.pi = None  # Predecessor
                self.line_id = None  # Line ID
                self.departure_time = None

        
        vertices = {terminal: Vertex(terminal) for terminal in self.adjacency_list.keys()}
        #initialise the dictionary to store terminal names and values as instances of the Vertex class,
        #which creates a vertex for each terminal in the network
        
        origin_departure_time = time + 1
        #i understand the above line is incorrect
        vertices[origin].d = origin_departure_time
    
        
        # Initialize deque with the origin vertex to BFS the graph
        queue = deque([vertices[origin]])

        # Dijkstra's algorithm
        while queue:
            curr_vertex = queue.popleft()
            curr_terminal = curr_vertex.name

            #iterates over neighbours. for each neighbour, calculates the arrival time at the neighbor terminal and updates the required values if a faster route is found. 
            for neighbor, departure_time, arrival_time, line_id in self.adjacency_list.get(curr_terminal, []):
                new_arrival = max(arrival_time, curr_vertex.d + departure_time)
                if new_arrival < vertices[neighbor].d:
                    vertices[neighbor].d = new_arrival
                    vertices[neighbor].pi = curr_vertex
                    vertices[neighbor].line_id = line_id
                    vertices[neighbor].departure_time = max(arrival_time, curr_vertex.d + departure_time)
                    queue.append(vertices[neighbor])

        #Reconstructs the shortest path from the destination back to the origin by following the predecessor pointers (pi) from the destination vertex. 
        #Each vertex along the path is added to the path list along with its departure time and line ID.
        path = []
        current_vertex = vertices[destination]
        while current_vertex.pi:
            path.append((current_vertex.name, current_vertex.departure_time, current_vertex.line_id))
            current_vertex = current_vertex.pi
    
        # Reverse the path to get the correct order
        path.reverse()
    
        # Append the destination with arrival time and None line_id
        path.append((destination, vertices[destination].d, None))
        path.insert(0, (origin, vertices[origin].d, vertices[origin].line_id))
        #Inserts the origin terminal at the beginning of the path with its departure time and line ID.
        
        return path
        


# The following is for testing the implementation of Submarine Network.
if __name__== '__main__':

    network = SubmarineNetwork()
    
    s = ( "South Sea", "Indian Ocean", "Coral Reef", "Polar Lagoon",
          "South Sandwich Trench", "Mariana Trench", "Brazil Basin")
    
    network.add_line([ (s[0],12), (s[1],52), (s[2],74), (s[3],123) ])
    network.add_line([ (s[0],40), (s[1],110), (s[2],140), (s[3],150) ])
    network.add_line([ (s[4],57), (s[0],60), (s[1],65), (s[2],70), (s[3],80) ])
    network.add_line([ (s[3],145), (s[1],172), (s[0],203) ])
    network.add_line([ (s[5],21), (s[1],26), (s[0],74) ])
    network.add_line([ (s[0],78), (s[2],102), (s[3],120), (s[5],164), (s[1],183) ])
    network.add_line([ (s[6],23), (s[4],55), (s[3],125), (s[0],154), (s[1],200) ])
    network.add_line([ (s[6],12), (s[4],15), (s[5],20), (s[0],54), (s[1],75) ])

    print( "The lines stopping at \'" + s[1] + "\' between 55 and 200" )
    print( "as list of (line, time) are:" )
    print( network.lines_stopping_at(s[1],55,200) )
    print()
    
    for i_from,i_to,after in ( (0,3,20), (6,2,10), (3,6,0), (0,5,500), (0,5,20) ): 
        print( "from \'" + s[i_from] + "\' to \'" + s[i_to] + "\' leaving after " + str(after) )
        print( "   fastest direct connection as (line, time from, time to): "
               +  str( network.best_direct_connection(s[i_from], s[i_to], after) )
             )
        
        L = network.next_fastest_connection(s[i_from], s[i_to], after)
        if L == None:
            print( "   fastest connection as list of (terminal, time, line): None" )
        else:
            print( "   fastest connection as list of (terminal, time, line):" )
            for x in L:
                print( "      " + str(x) )
        print()

'''
List any acknowledgements or references here.

https://www.youtube.com/watch?v=XB4MIexjvY0
Introduction to Algorithms - CLRS
^ very heavily used CLRS book to help me calculate running times and make design decisions
https://softwareengineering.stackexchange.com/questions/258509/algorithms-how-do-i-sum-on-and-onlogn-together
https://gist.github.com/mdiener21/f2d514bd9187e0df9d88d3c00a01fc1d
https://codereview.stackexchange.com/questions/254420/dijkstras-algorithm-in-graph-python
https://codereview.stackexchange.com/questions/254420/dijkstras-algorithm-in-graph-python

'''









'''
Possible output after successful implementation:

The lines stopping at 'Indian Ocean' between 55 and 200
as list of (line, time) are:
[(2, 65), (7, 75), (1, 110), (3, 172), (5, 183), (6, 200)]

from 'South Sea' to 'Polar Lagoon' leaving after 20
   fastest direct connection as (line, time from, time to): (2, 60, 80)
   fastest connection as list of (terminal, time, line):
      ('South Sea', 60, 2)
      ('Indian Ocean', 65, 2)
      ('Coral Reef', 70, 2)
      ('Polar Lagoon', 80, None)

from 'Brazil Basin' to 'Coral Reef' leaving after 10
   fastest direct connection as (line, time from, time to): None
   fastest connection as list of (terminal, time, line):
      ('Brazil Basin', 12, 7)
      ('South Sandwich Trench', 15, 7)
      ('Mariana Trench', 21, 4)
      ('Indian Ocean', 65, 2)
      ('Coral Reef', 70, None)

from 'Polar Lagoon' to 'Brazil Basin' leaving after 0
   fastest direct connection as (line, time from, time to): None
   fastest connection as list of (terminal, time, line): None

from 'South Sea' to 'Mariana Trench' leaving after 500
   fastest direct connection as (line, time from, time to): None
   fastest connection as list of (terminal, time, line): None

from 'South Sea' to 'Mariana Trench' leaving after 20
   fastest direct connection as (line, time from, time to): (5, 78, 164)
   fastest connection as list of (terminal, time, line):
      ('South Sea', 60, 2)
      ('Indian Ocean', 65, 2)
      ('Coral Reef', 70, 2)
      ('Polar Lagoon', 120, 5)
      ('Mariana Trench', 164, None)
'''
