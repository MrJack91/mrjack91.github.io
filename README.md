using https://github.com/jekyll/minima




Windows:
podman build -t mrjack91 .
podman run --rm -it -v ".:/srv/jekyll:z" -p 4000:4000 -p 35729:35729 localhost/mrjack91
