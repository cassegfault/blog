if command -v openring &> /dev/null
then
openring \
  -s https://danluu.com/atom.xml \
  -s https://drewdevault.com/blog/index.xml \
  -s https://jvns.ca/atom.xml \
  -s http://rachelbythebay.com/w/atom.xml \
  -s http://journal.stuffwithstuff.com/rss.xml \
  -s https://www.taniarascia.com/rss.xml \
  < webring-in.template \
  > layouts/partials/webring-out.html
fi

hugo
