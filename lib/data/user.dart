class User {
  const User({required this.id, required this.name, required this.initials});
  final int id;
  final String name;
  final String initials;
}

const mockUsers = <User>[
  User(id: 1, name: 'Alex Fischer', initials: 'AF'),
  User(id: 2, name: 'Mira Weber', initials: 'MW'),
  User(id: 3, name: 'Sam Müller', initials: 'SM'),
  User(id: 4, name: 'Lena Schneider', initials: 'LS'),
  User(id: 5, name: 'Jonas Bauer', initials: 'JB'),
  User(id: 6, name: 'Emma Vogel', initials: 'EV'),
  User(id: 7, name: 'Paul Neumann', initials: 'PN'),
  User(id: 8, name: 'Clara Hoffmann', initials: 'CH'),
  User(id: 9, name: 'Felix Brandt', initials: 'FB'),
  User(id: 10, name: 'Nina Krüger', initials: 'NK'),
];
