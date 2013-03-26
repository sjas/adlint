Feature: W1052

  W1052 detects that an arithmetic operation of unsigned values may be
  overflow.

  Scenario: multiplication of two arbitrary `unsigned char' values
    Given a target source named "fixture.c" with:
      """
      static unsigned int foo(unsigned char a, unsigned char b)
      {
          return a * b; /* W1052 should not be output */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 21     |
      | W0246 | 3    | 12     |
      | W0246 | 3    | 16     |
      | W0167 | 3    | 14     |
      | W0303 | 3    | 5      |
      | W0104 | 1    | 39     |
      | W0104 | 1    | 56     |
      | W0629 | 1    | 21     |
      | W0628 | 1    | 21     |

  Scenario: multiplication of two arbitrary `unsigned short' values
    Given a target source named "fixture.c" with:
      """
      static unsigned int foo(unsigned short a, unsigned short b)
      {
          return a * b; /* W1052 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 21     |
      | W0248 | 3    | 12     |
      | W0248 | 3    | 16     |
      | W1052 | 3    | 14     |
      | W0167 | 3    | 14     |
      | W0303 | 3    | 5      |
      | W0104 | 1    | 40     |
      | W0104 | 1    | 58     |
      | W0629 | 1    | 21     |
      | W0628 | 1    | 21     |

  Scenario: multiplication of two arbitrary `unsigned int' values
    Given a target source named "fixture.c" with:
      """
      static unsigned int foo(unsigned int a, unsigned int b)
      {
          return a * b; /* W1052 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 21     |
      | W1052 | 3    | 14     |
      | W0104 | 1    | 38     |
      | W0104 | 1    | 54     |
      | W0629 | 1    | 21     |
      | W0628 | 1    | 21     |
