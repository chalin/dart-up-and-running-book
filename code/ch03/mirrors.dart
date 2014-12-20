import 'dart:mirrors';

askUserForNameOfFunction() => 'foo';

class Person {
  String firstName;
  String lastName;
  int age;

  Person(this.firstName, this.lastName, this.age);

  String get fullName => '$firstName $lastName';

  void greet(String other) {
    print('Hello there, $other!');
  }
}

main() {
  // If the symbol name is known at compile time.
  const className = #MyClass;

  // If the symbol name is dynamically determined.
  var userInput = askUserForNameOfFunction();
  var functionName = new Symbol(userInput);

  print('className = ${MirrorSystem.getName(className)}');
  assert('MyClass' == MirrorSystem.getName(className));
  assert('MyClass' == MirrorSystem.getName(#MyClass));

  ClassMirror mirror = reflectClass(Person);
  assert('Person' ==
      MirrorSystem.getName(mirror.simpleName));

  reflectFromInstance();
  showConstructors(mirror);
  showFields(mirror);
  reflectOnInstance();
}

reflectFromInstance() {
  var person = new Person('Bob', 'Smith', 33);
  ClassMirror mirror = reflectClass(person.runtimeType);
  assert('Person' ==
      MirrorSystem.getName(mirror.simpleName));
}

showConstructors(ClassMirror mirror) {
  var constructors = mirror.declarations.values
      .where((m) => m is MethodMirror && m.isConstructor);

  constructors.forEach((m) {
    print('The constructor ${m.simpleName} has '
          '${m.parameters.length} parameters.');
  });
}

showFields(ClassMirror mirror) {
  var fields = mirror.declarations.values
      .where((m) => m is VariableMirror);

  fields.forEach((VariableMirror m) {
    var finalStatus = m.isFinal ? 'final' : 'not final';
    var privateStatus = m.isPrivate ?
        'private' : 'not private';
    var typeAnnotation = m.type.simpleName;

    print('The field ${m.simpleName} is $privateStatus ' +
          'and $finalStatus and is annotated as ' +
          '$typeAnnotation.');
  });
}

reflectOnInstance() {
  var p = new Person('Bob', 'Smith', 42);
  InstanceMirror mirror = reflect(p);

  // Get the object that the mirror reflects.
  var person = mirror.reflectee;
  assert(identical(p, person));

  // Invoke a method on the object.
  mirror.invoke(#greet, ['Shailen']);

  // Get the value of a property.
  var fullName = mirror.getField(#fullName).reflectee;
  assert(fullName == 'Bob Smith');

  // Set the value of a property.
  mirror.setField(#firstName, 'Mary');
  assert(p.firstName == 'Mary');
  assert(p.fullName == 'Mary Smith');
}
