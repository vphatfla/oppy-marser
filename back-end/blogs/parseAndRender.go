package blogs

import (
	"fmt"
	"io/fs"
	"os"
	"path"
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
				Name: info.Name()[:len(info.Name())-3],
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
		newName := a.Name + ".html"
		
		p := path.Join(outDir, newName)
		f, err := os.Create(p)
		if err != nil {
			return fmt.Errorf("Error creating file %s -> %s", p, err.Error())
		}
		
		n, err := f.Write(a.HtmlContent)
		if err != nil {
			return fmt.Errorf("Error writing to file %s -> %s ", p, err.Error())
		}
		fmt.Printf("Write %d byte to %s \n", n, p) 
		defer f.Close()
	}
	return nil
}
// Render HTML content from markdown (.md) files
func Render(inDir string, outDir string) error {
	articles, err := readMdInput(inDir)
	
	if err != nil {
		return fmt.Errorf("Error reading .md files ->  %s \n", err.Error())
	}

	p := parser.New()

	flags := html.HrefTargetBlank
	opts := html.RendererOptions{Flags: flags}
	r := html.NewRenderer(opts)

	for i := range articles {
		// for loops e is only a copy of ar[i]
		// fmt.Printf("%p vs %p", &articles[i], &a)
		doc := p.Parse(articles[i].MdContent)
		articles[i].HtmlContent = markdown.Render(doc, r)
	}
	
	err = writeHtmlOutput(outDir, articles)
	
	if err != nil {
		return fmt.Errorf("Error writing .html files %q \n", err)
	}
	return nil
}
