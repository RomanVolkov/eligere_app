
<h1 align='center'>
    Eligere app
</h1>

<p align="center">
    <img src="./docs/images/open_link_example.png" width="40%"
</p>


<p align="center">
a Lightweight, <b>easy-to-use</b> and <b>easy-to-configure</b> macOS app.

Eligere routes every link to the right browser via simple <b>TOML</b> configuration
</p>

<p></p>

<details>
     <summary>Config example</summary>

```toml
useOnlyRunningBrowsers = false
stripTrackingAttributes = true
expandShortenURLs = true
pinningSeconds = 30
logLevel = "warning"
[[browsers]]
name = "Safari"
shortcut = "s"
apps = ["Messages"]
domains = ["apple.com"]
[[browsers]]
name = "Arc"
shortcut = "a"
apps = ["Slack"]
domains = ["github.com"]
```

</details>

### Why choose Eligere?

When you click on a link outside of your web browser it opens in your default web browser. If you use more than one web browser on a regular basis having a single default web browser can be very restrictive and hard to use.  That's where Eligere comes in: instead of having a single default browser Eligere opens links in the right browser for that particular situation based on configuration you created


### Features

- Configure the app using a simple TOML file, no complex UI needed.
- Automatically strip tracking attributes like utm_source from URLs.
- Assign specific domains to open in designated browsers.
- Use shortcuts to quickly open links in your preferred browser.
- Map specific source apps to open links in designated browsers.
- Find more in [docs](./docs/config.md)

### Download & Install

Single line command will do the trick

```bash
brew install --cask romanvolkov/eligere/eligere
```


### First launch 

Once you installed `Eligere.app` via `brew install` you will need to do some steps to make `Eligere` as the default web browser. You can find steps [here.](./docs/first_launch.md)

### Configuration

As it mentioned before - `Eligere's` main difference from other apps like this is using a `TOML` configuration instead. `Eligere` comes with predefined configuration as starter. But then you should configure it how you like it. [There is a detailed guide](./docs/config.md): where to find the config, how to edit and some examples to get inspiration from.

### Troubleshooting

If you have some problems - you can enable verbose login and open an Issue here. Here is how you can do it:  [logs](./docs/logs.md)

### Sponsorship

`Eligere` is developed and maintained in my free time.
If you find it useful, [consider sponsoring](https://github.com/sponsors/romanvolkov#sponsors).
