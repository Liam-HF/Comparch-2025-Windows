import random

register = []
add_list = [0,1]
data_out = ''
def get_ratio(register):
    sum = 0
    for bit in register:
        sum += bit
    ratio = sum/len(register)
    print(ratio)
    return ratio

for i in range(64):
    register.append(random.choice(add_list))
    if get_ratio(register) > 0.33:
        add_list.append(0)
    else:
        add_list.append(1)

print(len(add_list))

for element in register:
    data_out += str(element)


print(len(data_out))
print(data_out)