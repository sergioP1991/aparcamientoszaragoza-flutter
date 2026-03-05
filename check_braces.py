with open('lib/Screens/admin/admin_rentals_screen.dart', 'r') as f:
    lines = f.readlines()

balance = 0
for line_num, line in enumerate(lines, 1):
    for char in line:
        if char == '{':
            balance += 1
        elif char == '}':
            balance -= 1
    
    if balance < 0:
        print(f"DESBALANCE a línea {line_num}: balance = {balance}")
        print(f"Línea: {line.strip()}")
        break

if balance >= 0:
    print(f"Final balance: {balance}")
    if balance > 0:
        print(f"Faltan {balance} cierres"}
