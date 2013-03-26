Feature: W0655

  W0655 detects that a bit-field member appears as an operand of the
  sizeof-expression.

  Scenario: bit-field as an operand
    Given a target source named "fixture.c" with:
      """
      extern struct Foo { unsigned int b1:1, b2:1; } foo;

      static unsigned long bar(void)
      {
          return sizeof(foo.b1); /* W0655 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 48     |
      | W1076 | 3    | 22     |
      | W0655 | 5    | 12     |
      | W0629 | 3    | 22     |
      | W0425 | 1    | 40     |
      | W0628 | 3    | 22     |

  Scenario: arithmetic expression of two bit-fields as an operand
    Given a target source named "fixture.c" with:
      """
      extern struct Foo { unsigned int b1:1, b2:1; } foo;

      static unsigned long bar(void)
      {
          return sizeof(foo.b1 + foo.b2); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 48     |
      | W1076 | 3    | 22     |
      | W0629 | 3    | 22     |
      | W0425 | 1    | 40     |
      | W0628 | 3    | 22     |
