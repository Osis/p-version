Feature: Bumping the alpha version for a pivotal product
Given I want to increment the alpha version of a pivotal product
As a developer or a CI server
Then I need to be able to pass the relevant information into the command line

  Background: Running the command
    Given a file named "metadata_parts/binaries.yml" with:
    """
    ---
    name: example-product
    product_version: 1.2.3.4-alpha32
    metadata_version: '1.2'
    provides_product_versions:
      - name: example-product
        version: 1.2.3.4-alpha32
    stemcell:
      name: foo
      version: '1'
      file: a_stemcell.tgz
      md5: d41d8cd98f00b204e9800998ecf8427e
    releases:
    - file: cf-158.1-dev.tgz
      name: cf
      version: '158.1-dev'
      md5: d41d8cd98f00b204e9800998ecf8427e
    """
    And a file named "content_migrations/migration.yml" with:
    """
    ---
    product: cf
    installation_version: "1.1"
    to_version: "1.2.3.4-alpha32"
    migrations:
      - from_version: 1.0.0.1
        rules:
          - type: update
            selector: "product_version"
            to: "1.2.3.4-alpha32"
    """

    When I run `bump_alpha_version --product-dir=.`

  Scenario: Exit status
    Then the exit status should be 0

  Scenario: Helpful output upon successful .pivotal and materials creation
    Then the output should match /incrementing version from 1.2.3.4-alpha32 to 1.2.3.4-alpha33/
    And a file named "metadata_parts/binaries.yml" should exist

  Scenario: Checking that the binaries.yml is updated
    When I run `grep -A2 product_version metadata_parts/binaries.yml`
    Then the output should match /product_version: 1.2.3.4-alpha33/
    Then the output should match /- name: example-product\s+version: 1.2.3.4-alpha33/

  Scenario: Checking that content_migrations .yml is updated
    When I run `grep 1.2.3.4-alpha33 content_migrations/migration.yml`
    Then the output should match /to_version: 1.2.3.4-alpha33/
    And the output should match /to: 1.2.3.4-alpha33/
