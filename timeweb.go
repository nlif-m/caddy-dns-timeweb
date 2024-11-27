package timewebcaddy

import (
	"github.com/caddyserver/caddy/v2"
	"github.com/caddyserver/caddy/v2/caddyconfig/caddyfile"
	"github.com/libdns/timeweb"
)

// Provider lets Caddy read and manipulate DNS records hosted by this DNS provider.
type Provider struct{ *timeweb.Provider }

func init() {
	caddy.RegisterModule(Provider{})
}

// CaddyModule returns the Caddy module information.
func (Provider) CaddyModule() caddy.ModuleInfo {
	return caddy.ModuleInfo{
		ID:  "dns.providers.timeweb",
		New: func() caddy.Module { return &Provider{&timeweb.Provider{}} },
	}
}

// Provision sets up the module. Implements caddy.Provisioner.
func (p *Provider) Provision(ctx caddy.Context) error {
	p.Provider.ApiURL = caddy.NewReplacer().ReplaceAll(p.Provider.ApiURL, "")
	p.Provider.ApiToken = caddy.NewReplacer().ReplaceAll(p.Provider.ApiToken, "")
	return nil
}

func (p *Provider) UnmarshalCaddyfile(d *caddyfile.Dispenser) error {

	for d.Next() {
		for nesting := d.Nesting(); d.NextBlock(nesting); {
			switch d.Val() {
			case "api_token":
				if p.Provider.ApiToken != "" {
					return d.Err("ApiToken already set")
				}
				if d.NextArg() {
					p.Provider.ApiToken = d.Val()
				}
				if d.NextArg() {
					return d.ArgErr()
				}
			default:
				return d.Errf("unrecognized subdirective '%s'", d.Val())
			}
		}
	}

	p.Provider.ApiURL = "https://api.timeweb.cloud/api/v1"
	if p.Provider.ApiURL == "" {
		return d.Err("missing ApiURL")
	}
	if p.Provider.ApiToken == "" {
		return d.Err("missing ApiToken")
	}

	return nil
}

// Interface guards
var (
	_ caddyfile.Unmarshaler = (*Provider)(nil)
	_ caddy.Provisioner     = (*Provider)(nil)
)
