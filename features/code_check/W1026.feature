Feature: W1026

  W1026 detects that type of an argument is incomplete.

  Scenario: incomplete struct type as an argument
    Given a target source named "fixture.c" with:
      """
      extern struct st s;
      extern void foo(struct st);

      void bar(void)
      {
          foo(s); /* W1026 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 1    | 18     |
      | W0118 | 2    | 13     |
      | W0117 | 4    | 6      |
      | W0493 | 6    | 8      |
      | W1026 | 6    | 9      |
      | W0628 | 4    | 6      |

  Scenario: incomplete typedef-ed struct type as an argument
    Given a target source named "fixture.c" with:
      """
      typedef struct st st_t;

      extern st_t s;
      extern void foo(st_t);

      void bar(void)
      {
          foo(s); /* W1026 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 3    | 13     |
      | W0625 | 1    | 19     |
      | W0118 | 4    | 13     |
      | W0117 | 6    | 6      |
      | W0493 | 8    | 8      |
      | W1026 | 8    | 9      |
      | W0628 | 6    | 6      |

  Scenario: complete struct type as an argument
    Given a target source named "fixture.c" with:
      """
      typedef struct {
          int i;
      } st_t;

      extern st_t s;
      extern void foo(st_t);

      void bar(void)
      {
          foo(s); /* OK */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 5    | 13     |
      | W0625 | 3    | 3      |
      | W0118 | 6    | 13     |
      | W0117 | 8    | 6      |
      | W0493 | 10   | 8      |
      | W0628 | 8    | 6      |

  Scenario: multiple incomplete typed arguments
    Given a target source named "fixture.c" with:
      """
      typedef struct st st_t;
      typedef enum en en_t;

      extern st_t s;
      extern en_t e;
      extern void foo(st_t, int, en_t);

      void bar(void)
      {
          foo(s, 0, e); /* two W1026 */
      }
      """
    When I successfully run `adlint fixture.c` on noarch
    Then the output should exactly match with:
      | mesg  | line | column |
      | W0118 | 4    | 13     |
      | W0625 | 1    | 19     |
      | W0118 | 5    | 13     |
      | W0625 | 2    | 17     |
      | W0737 | 5    | 13     |
      | W0118 | 6    | 13     |
      | W0117 | 8    | 6      |
      | W0493 | 10   | 8      |
      | W1026 | 10   | 9      |
      | W1026 | 10   | 15     |
      | W0628 | 8    | 6      |
