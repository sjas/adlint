Feature: W0492

  W0492 detects that the same name appears in different namespaces.

  Scenario: hard to parse
    Given a target source named "fixture.c" with:
      """
      typedef int foo;

      foo bar(foo baz)
      {
          goto foo;
      foo:
          return baz;
      }

      struct foo { foo foo, (*bar)(foo); };
      union bar { foo foo, (*bar)(foo (*baz)(foo)); };
      enum baz { baz };

      struct {
          foo    :1;
          foo foo:1;
          foo    :1;
          foo bar:1;
          foo    :1;
      } qux;

      struct qux {
          foo;
          union bar bar;
      };

      int const long volatile unsigned cv_ulong;
      const foo volatile cv_foo;
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0117 | 3    | 5      |
      | W0625 | 1    | 13     |
      | W0491 | 6    | 1      |
      | C0001 | 1    | 13     |
      | W0104 | 3    | 13     |
      | W0491 | 10   | 8      |
      | C0001 | 1    | 13     |
      | W0492 | 10   | 18     |
      | C0001 | 1    | 13     |
      | C0001 | 10   | 8      |
      | W0492 | 11   | 7      |
      | C0001 | 10   | 25     |
      | W0492 | 11   | 17     |
      | C0001 | 1    | 13     |
      | C0001 | 10   | 8      |
      | W0492 | 11   | 24     |
      | C0001 | 11   | 7      |
      | W0492 | 16   | 9      |
      | C0001 | 1    | 13     |
      | C0001 | 10   | 8      |
      | W0492 | 18   | 9      |
      | C0001 | 11   | 7      |
      | W0117 | 20   | 3      |
      | W0491 | 22   | 8      |
      | C0001 | 20   | 3      |
      | W0492 | 24   | 15     |
      | C0001 | 11   | 7      |
      | W0080 | 27   | 34     |
      | W0117 | 27   | 34     |
      | W0080 | 28   | 20     |
      | W0117 | 28   | 20     |
      | W1072 | 5    | 5      |
      | W0551 | 11   | 7      |
      | W0525 | 16   | 9      |
      | W0525 | 18   | 9      |
      | W0040 | 14   | 1      |
      | W0425 | 10   | 25     |
      | W0425 | 11   | 24     |
      | W0431 | 6    | 1      |
      | W0432 | 6    | 1      |
      | W0628 | 3    | 5      |
