
prog = int(input('Choose an option ')) # add \n in all correct places for results to drop line


while prog !=4:

  if prog == 1:

    row_width = int(input('Please enter number of rows '))


    for line_number in range(0,int(row_width/2)):
      for space_number in range(0,line_number):
        print(' ', end='')
      for star_number in range(0,row_width-line_number*2):
        print('*', end='')
      print('\n')

    if row_width%2 !=0:
      for space_number in range(0,line_number+1):
       print(' ', end='')
      print('*\n')

    for line_number in range(int(row_width/2)-1,-1,-1):
      for space_number in range(0,line_number):
        print(' ', end='')
      for star_number in range(0,row_width-line_number*2):
        print('*', end='')
      print('\n')


  elif prog == 2: #2

    num = 0
    l1=[]

    while num!= -1:
      num = int(input('Please enter a number '))
      print(num) #delete this print
      if num > 10:
        l1.append(num)
    l1.sort()
    print('The numbers are')

    for element in l1:
       print(element)

  elif prog == 3: #q3

    num = 0
    l1=[]
    l1_unique =[]

    while num!= -1:
      num = int(input('Please enter a number '))
      print(num)
      if num == -1:
        break
      l1.append(num)
      if num not in l1_unique:
        l1_unique.append(num)


    print('The numbers are')


    for element in l1_unique:
      print(str(element) + ' entered ' + str(l1.count(element))+ ' times')


  else:
      print('error Input')
  prog = int(input('Choose an option '))

print('Bye')
