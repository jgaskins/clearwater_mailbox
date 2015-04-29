# Clearwater-Mailbox

This is a port of Tryo Labs' [React Mailbox](http://blog.tryolabs.com/2015/04/07/react-examples-mailbox/) example to Clearwater with the virtual DOM.

## Routing

One major difference between using their React version and this version is that this version uses Clearwater's router to manage some of the state rather than storing it in components. The result is that when you refresh, you are in the same place rather than looking at a fresh app.

Here are the routes we're using:

```ruby
Clearwater::Router.new do
  mailbox = Mailbox.new
  route ':mailbox_id' => mailbox do
    route ':email_id' => Email.new(mailbox: mailbox)
  end
end
```

This means that when we visit `/1/2`, we're looking at the second email in the first mailbox. We pass the parent component into the child component for convenience.
