# Notes

Umami version 1.39.5 has some problems on monitoring events on Firefox if using the "CSS classes method".

I've found it working very well with something (a bit ugly I know) like this:

```Javascript
const action = async (event: any, href: string, target?: string, trackingId?: string, onClick?: Function) => {
  event.preventDefault();
  if (trackingId === undefined) return
  if (window.umami) {
    await window.umami(trackingId)
  }
  if (onClick) onClick()
  if (!target) {
    window.open(href, "_self")
  } else {
    window.open(href, target)
  }
}

export default function Anchor({ href, target, rel, trackingId, className, onClick, children }: AnchorType) {
  return ( 
    <a className={`${className ? className : ''} ${styles.anchor}`} onClick={(event) => action(event, href, target, trackingId, onClick)}>
      { children }
    </a>
  )}
```

And then using it like:

```Javascript
<Anchor href="/index.html" trackingId={`project-website`}>
  <Button variant="light" fullWidth mt="md" radius="md">
    You are already here
  </Button>
</Anchor>
```
