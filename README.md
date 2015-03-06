# Pair Programming Atom package

This atom package allows you to **broadcast your atom text editor** in real time on the web.
The idea is to be able to create **"programming channels"** just as **"Youtube channels"**. It's sometimes fun to look at others programming (I wonder whether it's a normal behavior though...). <br/>
It might just also be interesting in terms of learning good habits, learning best practices or even finding bugs and pair programming...<br/>

This package can also be used for **teaching concerns**. For example, you have a class of people learning to code. You activate the package and ask the students to connect the channel and participate in a coding session.

This is a kind of "Twitch for code" (I don't really subscribe to this X for Y but...).

I'm quite new to atom package and coffeeScript so there are probably some ugly things here and there but it's here at least :-)

On the other hand, It'll be awesome to create an API (on the server side) for other editor fans to be able to develop package for other editor (sublime, emacs, vi etc...)

## Access streaming
Everybody can see live channels of programmer broadcasting their code on **[gearhunt.net][gearhunt]**, then choose a channel and watch TV 😄

## Installation
Menu > Atom > Preferences > Install then search for "Pair programming" and install the package

## Shortcuts

### ctrl-alt-y -> Activate broadcast

From now on every open panes (tabs) will be visible as you type, copy, paste, scroll.

### ctra-alt-t -> Deactivate broadcast

From now on you are disconnected and nothing is shared anymore.

## Infos

When you broadcast a small owl (cool animal isn't it ?) is added to your status bar with the number of watchers next to it.<br/> This number is automatically updated as people are following you or leaving :-)

![Owl](https://github.com/PierreVannier/pair-programming/blob/master/owl.png?raw=true "The owl is watching you")

## Cool features to add
- View the country where the programmer is located (with a small flag on the server)<br/>
- Possibility to integrate a chat interface (Hip Chat?)<br/>
- Enhance performances (if needed :-) )
- allow user to select which pane or editor he wants to share




Find more information concerning Atom package creation [here][atom-doc].

[npm]: https://www.npmjs.org/package/generator-atom-package
[atom-doc]: https://atom.io/docs/latest/creating-a-package "Official documentation"
[gearhunt]: https://gearhunt.net
