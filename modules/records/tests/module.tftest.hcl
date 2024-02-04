run "parses_variables" {
  variables {
    primary = "www.example.com"
    domains = [
      "www.example.com",
      "foo.example.com",
      "bar.example.com",
      "example.com",
      "www.example.org",
      "example.net"
    ]
  }

  assert {
    condition = output.mapped_zones == {
      "example.com" = {
        a = ["example.com"]
        cname = [
          "www.example.com",
          "foo.example.com",
          "bar.example.com",
        ]
      }
      "example.net" = {
        a     = ["example.net"]
        cname = []
      }
      "example.org" = {
        a     = [],
        cname = ["www.example.org"]
      }
    }
    error_message = "Mapped zones output should split input domains by top-level domain, then by CNAME and A records"
  }

  assert {
    condition = output.zones == [
      {
        record      = "example.com"
        record_type = "a"
        zone        = "example.com"
      },
      {
        record      = "www.example.com"
        record_type = "cname"
        zone        = "example.com"
      },
      {
        record      = "foo.example.com"
        record_type = "cname"
        zone        = "example.com"
      },
      {
        record      = "bar.example.com"
        record_type = "cname"
        zone        = "example.com"
      },
      {
        record      = "example.net"
        record_type = "a"
        zone        = "example.net"
      },
      {
        record      = "www.example.org"
        record_type = "cname"
        zone        = "example.org"
      }
    ]
    error_message = "Zones output should be flat list of { zone, record_type, record } objects"
  }

  assert {
    condition     = output.domains == var.domains
    error_message = "Domains output should pass domains input directly"
  }

  assert {
    condition     = !contains(output.redirects, var.primary)
    error_message = "Redirects output should exclude primary input"
  }
}

run "empty_output_is_ok" {
  variables {
    primary = "www.example.com"
    domains = ["www.example.com"]
  }

  assert {
    condition = output.mapped_zones == {
      "example.com" = {
        cname = ["www.example.com"],
        a     = []
      }
    }
    error_message = "Mapped zones output should split input domains by top-level domain, then by CNAME and A records"
  }

  assert {
    condition = output.zones == [
      {
        zone        = "example.com",
        record_type = "cname",
        record      = "www.example.com"
      }
    ]
    error_message = "Zones output should be flat list of { zone, record_type, record } objects"
  }

  assert {
    condition     = length(output.redirects) == 0
    error_message = "Redirects output should be empty if only one domain is provided"
  }
}
