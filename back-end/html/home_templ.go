// Code generated by templ - DO NOT EDIT.

// templ: version: v0.3.819
package html

//lint:file-ignore SA4006 This context is only used if a nested component is present.

import "github.com/a-h/templ"
import templruntime "github.com/a-h/templ/runtime"

func Home() templ.Component {
	return templruntime.GeneratedTemplate(func(templ_7745c5c3_Input templruntime.GeneratedComponentInput) (templ_7745c5c3_Err error) {
		templ_7745c5c3_W, ctx := templ_7745c5c3_Input.Writer, templ_7745c5c3_Input.Context
		if templ_7745c5c3_CtxErr := ctx.Err(); templ_7745c5c3_CtxErr != nil {
			return templ_7745c5c3_CtxErr
		}
		templ_7745c5c3_Buffer, templ_7745c5c3_IsBuffer := templruntime.GetBuffer(templ_7745c5c3_W)
		if !templ_7745c5c3_IsBuffer {
			defer func() {
				templ_7745c5c3_BufErr := templruntime.ReleaseBuffer(templ_7745c5c3_Buffer)
				if templ_7745c5c3_Err == nil {
					templ_7745c5c3_Err = templ_7745c5c3_BufErr
				}
			}()
		}
		ctx = templ.InitializeContext(ctx)
		templ_7745c5c3_Var1 := templ.GetChildren(ctx)
		if templ_7745c5c3_Var1 == nil {
			templ_7745c5c3_Var1 = templ.NopComponent
		}
		ctx = templ.ClearChildren(ctx)
		templ_7745c5c3_Err = templruntime.WriteString(templ_7745c5c3_Buffer, 1, "<div id=\"content\"><!-- Name / Hero Section --><section class=\"hero\"><h2>John Doe</h2><p>A passionate developer and designer, focused on crafting <br>modern, user-friendly experiences on the web.</p></section><!-- Introduction Section --><section class=\"introduction\"><h3>Introduction</h3><p>Hi! I’m John, a self-taught programmer based in San Francisco. I love experimenting with new technologies and improving user experiences. Whether it's building RESTful APIs or writing clean, maintainable frontend code, I'm always eager to learn more.</p></section><!-- Experience Section --><section class=\"experience\"><h3>Experience</h3><ul><li><strong>2018 - Present:</strong> Full-Stack Engineer at Acme Corp</li><li><strong>2015 - 2018:</strong> Frontend Developer at Creative Studio</li><li><strong>2013 - 2015:</strong> Freelance Web Designer</li></ul></section></div>")
		if templ_7745c5c3_Err != nil {
			return templ_7745c5c3_Err
		}
		return nil
	})
}

var _ = templruntime.GeneratedTemplate
