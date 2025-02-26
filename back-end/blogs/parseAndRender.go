package blogs

import (
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
	"strings"

	"github.com/gomarkdown/markdown"
	"github.com/gomarkdown/markdown/html"
	"github.com/gomarkdown/markdown/parser"
)

type BlogArticle struct {
	Name string
	MdContent []byte
	HtmlContent []byte
}
// Read []byte from .md file in the given folder
func readMdInput(inDir string) ([]BlogArticle, error) {
	var res []BlogArticle

	
	err := filepath.Walk(inDir, func(path string, info fs.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if info.IsDir() {
			return nil
		}

		if strings.ToLower(filepath.Ext(path)) == ".md" {
			content, err := os.ReadFile(path)
			
			if err != nil {
				return err

			}
			
			b := BlogArticle{
				Name: info.Name(),
				MdContent: content,
				HtmlContent: nil,
			}
			res = append(res, b)
		}

		return nil
	})

	return res, err
}

// Write []byte to .html files into the given folder
func writeHtmlOutput(outDir string, articles []BlogArticle) error {
	// Empty out the html folder
	entries, err := os.ReadDir(outDir)

	if err != nil {
		return fmt.Errorf("Error writing html output to %s with error %q", outDir, err)
	}

	for _, entry := range entries {
		path := filepath.Join(outDir, entry.Name())
		err := os.RemoveAll(path)
		if err != nil {
			return fmt.Errorf("Error removing file %s with error %q", path, err)
		}
	}
	
	for _, a := range articles {
		// path := filepath.Join(outDir, a.Name)
		fmt.Println("current name = ", a.Name)
	}
	return nil
}
// Render HTML content from markdown (.md) files
func Render() error {
	articles, err := readMdInput("./md")
	
	if err != nil {
		return fmt.Errorf("Error reading .md files %q \n", err)
	}

	p := parser.New()

	flags := html.HrefTargetBlank
	opts := html.RendererOptions{Flags: flags}
	r := html.NewRenderer(opts)

	for _, a := range articles {
		doc := p.Parse(a.MdContent)
		a.HtmlContent = markdown.Render(doc, r)	
	}
	
	err = writeHtmlOutput("./html", articles)
	
	if err != nil {
		return fmt.Errorf("Error writing .html files %q \n", err)
	}
	return nil
}
