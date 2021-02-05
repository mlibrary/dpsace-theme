# DSpace Theme

This repo contains the styles and template changes to the Mirage2 theme to applied to our DSpace 6.x instance ("Deep Blue").

To learn more about [Mirage 2 configuration and customization](https://wiki.lyrasis.org/display/DSDOC6x/Mirage+2+Configuration+and+Customization), see that documentation.

## Deployment

This is all manual as of February 2021. Contact [Jose Blanco](https://www.lib.umich.edu/users/blancoj) to arrange a deployment.

## Styles

`styles/_styles.scss` is added last in the theme build step, so you can assume this is the last file at the end of the stylesheet cascade.

## XSL templates

Customization here override Mirage2 themes. You can copy other files you want to modify to that folder as you go.

```
TODO:
- [ ] Add a `built` or `source` kind of directory here so what can be overriden can be examined.
- [ ] Upgrade development env to be modern and follow industry development practices. local development, git, automated deployment environments, documentation, ...
```
