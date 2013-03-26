Feature: W1047

  W1047 detects that an initializer of struct, union or array variable contains
  non-constant expressions.

  Scenario: initializing array with non-constant expressions
    Given a target source named "fixture.c" with:
      """
      int foo(int i, int j)
      {
          int a[] = { 0, i, j }; /* W1047 */
          return a[1];
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W1047 | 3    | 9      |
      | W0100 | 3    | 9      |
      | W0104 | 1    | 13     |
      | W0104 | 1    | 20     |
      | W0628 | 1    | 5      |

  Scenario: initializing struct with non-constant expressions
    Given a target source named "fixture.c" with:
      """
      struct Coord {
          int x;
          int y;
          int z;
      };

      int foo(int i, int j)
      {
          struct Coord c = { i, j, 0 }; /* W1047 */
          return c.y;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 7    | 5      |
      | W1047 | 9    | 18     |
      | W0100 | 9    | 18     |
      | W0104 | 7    | 13     |
      | W0104 | 7    | 20     |
      | W0628 | 7    | 5      |

  Scenario: initializing union with non-constant expressions
    Given a target source named "fixture.c" with:
      """
      struct Color {
          int r;
          int g;
          int b;
      };

      struct Coord {
          int x;
          int y;
      };

      struct Event {
          int type;
          union {
              struct Color color;
              struct Coord coord;
          } body;
      };

      int foo(int i, int j)
      {
          struct Event ev = { 0, { i, j, 0 } }; /* W1047 */
          return ev.body.color.g;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 20   | 5      |
      | W1047 | 22   | 18     |
      | W0100 | 22   | 18     |
      | W0104 | 20   | 13     |
      | W0104 | 20   | 20     |
      | W0551 | 14   | 5      |
      | W0628 | 20   | 5      |

  Scenario: initializing array with all constant expressions
    Given a target source named "fixture.c" with:
      """
      int foo(void)
      {
          int a[] = { 0, 1, 2 }; /* OK */
          return a[1];
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 1    | 5      |
      | W0100 | 3    | 9      |
      | W0628 | 1    | 5      |

  Scenario: initializing struct with all constant expressions
    Given a target source named "fixture.c" with:
      """
      struct Coord {
          int x;
          int y;
          int z;
      };

      int foo(void)
      {
          struct Coord c = { 2, 1, 0 }; /* OK */
          return c.y;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 7    | 5      |
      | W0100 | 9    | 18     |
      | W0628 | 7    | 5      |

  Scenario: initializing union with all constant expressions
    Given a target source named "fixture.c" with:
      """
      struct Color {
          int r;
          int g;
          int b;
      };

      struct Coord {
          int x;
          int y;
      };

      struct Event {
          int type;
          union {
              struct Color color;
              struct Coord coord;
          } body;
      };

      int foo(void)
      {
          struct Event ev = { 0, { 2, 1, 0 } }; /* OK */
          return ev.body.color.g;
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 20   | 5      |
      | W0100 | 22   | 18     |
      | W0551 | 14   | 5      |
      | W0628 | 20   | 5      |
