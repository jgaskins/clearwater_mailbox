require 'clearwater/application'

class Email
  include Clearwater::Component

  def initialize(mailbox:)
    @mailbox = mailbox
  end

  def email
    @mailbox.emails.find { |email| email.id == param(:email_id).to_i }
  end

  def render
    div({class_name: 'email'}, [
      dl({class_name: 'meta dl-horizontal'}, [
        dt(nil, 'From'),
        dd(nil, email.from),

        dt(nil, 'To'),
        dd(nil, email.to),

        dt(nil, 'Subject'),
        dd(nil, email.subject),
      ]),
      div({class_name: 'body', innerHTML: email.body}),
    ])
  end
end

class EmailList
  include Clearwater::Component

  attr_reader :emails, :mailbox_id

  def initialize(emails=[], mailbox_id:)
    @emails = emails
    @mailbox_id = mailbox_id
  end

  def render
    table({class_name: 'email-list table table-striped table-condensed'}, [
      thead(nil, [
        tr(nil, [
          th(nil, 'Subject'),
          th(nil, 'From'),
          th(nil, 'To'),
        ]),
      ]),
      tbody(nil, emails.map { |mail|
        EmailListItem.new(mail, mailbox_id: mailbox_id)
      }),
    ])
  end
end

class EmailListItem
  include Clearwater::Component

  attr_reader :email, :mailbox_id

  def initialize(email, mailbox_id:)
    @email = email
    @mailbox_id = mailbox_id
  end

  def render
    tr({key: email.id}, [
      td(nil, Link.new({href: "/#{mailbox_id}/#{email.id}"}, email.subject)),
      td(nil, email.from),
      td(nil, email.to),
    ])
  end
end

class NoneSelected
  include Clearwater::Component

  def initialize(text:)
    @text = text
  end

  def render
    div({class_name: 'none-selected alert alert-warning', role: 'alert'},
      "No #{@text} selected."
    )
  end
end

class Mailbox
  include Clearwater::Component

  def mailbox
    Fixtures.find { |mailbox| mailbox.id == param(:mailbox_id).to_i }
  end

  def emails
    mailbox.emails
  end

  def render
    div(nil, [
      EmailList.new(emails, mailbox_id: mailbox.id),
      div({class_name: 'email-viewer'}, outlet || NoneSelected.new(text: 'email'))
    ])
  end
end

class MailboxList
  include Clearwater::Component

  def mailbox_list
    Fixtures.map { |mailbox|
      li({class_name: 'list-group-item', key: mailbox.id}, [
        span({class_name: 'badge'}, mailbox.emails.size),
        Link.new({href: "/#{mailbox.id}"}, mailbox.name),
      ])
    }
  end

  def render
    div({class_name: 'col-md-2'}, [
      ul({class_name: 'mailboxes list-group'}, mailbox_list)
    ])
  end
end

class Layout
  include Clearwater::Component

  def render
    div({class_name: 'app row'}, [
      MailboxList.new,
      div({class_name: 'mailbox col-md-10'},
        div({class_name: 'panel panel-default'},
          div({class_name: 'panel-body'}, outlet || NoneSelected.new(text: 'mailbox'))
        )
      ),
    ])
  end
end

Fixtures = [
  {
    id: 1,
    name: "Inbox",
    emails: [
      {
        id: 1,
        from: "joe@tryolabs.com",
        to: "fernando@tryolabs.com",
        subject: "Meeting",
        body: "hi"
      },
      {
        id: 2,
        from: "newsbot@tryolabs.com",
        to: "fernando@tryolabs.com",
        subject: "News Digest",
        body: "<h1>Intro to React</h1> <img src='https://raw.githubusercontent.com/wiki/facebook/react/react-logo-1000-transparent.png' width=300/)>"
      }
    ]
  },
  {
    id: 2,
    name: "Spam",
    emails: [
      {
        id: 3,
        from: "nigerian.prince@gmail.com",
        to: "fernando@tryolabs.com",
        subject: "Obivous 419 scam",
        body: "You've won the prize!!!1!1!!!"
      }
    ]
  }
]

class Hash
  def method_missing message
    if key? message
      self[message]
    else
      super
    end
  end
end

router = Clearwater::Router.new do
  mailbox = Mailbox.new

  route ':mailbox_id' => mailbox do
    route ':email_id' => Email.new(mailbox: mailbox)
  end
end

App = Clearwater::Application.new(
  component: Layout.new(Fixtures),
  router: router
)

$document.ready { App.call }
