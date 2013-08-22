Feature: W0570

  W0570 detects that a signed left-shift expression may cause undefined
  behavior because of overflow.

  Scenario: left-shift expression with `int' operand
    Given a target source named "fixture.c" with:
      """
      static void foo(int i)
      {
          if (i > 0 && i <= 0x1FFFFFFF) {
              i << 1; /* OK */
              i << 2; /* OK */
              i << 3; /* W0570 */
              i << 4; /* W0570 */
          }
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W1076 | 1    | 13     |
      | W0076 | 3    | 23     |
      | W0572 | 4    | 11     |
      | W0794 | 4    | 11     |
      | W0572 | 5    | 11     |
      | W0794 | 5    | 11     |
      | W0570 | 6    | 11     |
      | C1000 |      |        |
      | C1006 | 1    | 21     |
      | W0572 | 6    | 11     |
      | W0794 | 6    | 11     |
      | W0570 | 7    | 11     |
      | C1000 |      |        |
      | C1006 | 1    | 21     |
      | W0572 | 7    | 11     |
      | W0794 | 7    | 11     |
      | W0104 | 1    | 21     |
      | W0629 | 1    | 13     |
      | W0490 | 3    | 9      |
      | W0499 | 3    | 9      |
      | W0502 | 3    | 9      |
      | W0085 | 4    | 9      |
      | W0085 | 5    | 9      |
      | W0085 | 6    | 9      |
      | W0085 | 7    | 9      |
      | W0628 | 1    | 13     |
