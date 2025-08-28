# Eligere app
a Lightweight, **easy-to-use** and **easy-to-configure** macOS app. Eligere routes every link to the right browser via simple **TOML** configuration
![Eligere app](./docs/images/eligere.png "Image of Eligere app")

### Why choose Eligere?
> When you click on a link outside of your web browser it opens in your default web browser. If you use more than one web browser on a regular basis having a single default web browser can be very restrictive and hard to use.  That's where Eligere comes in: instead of having a single default browser Eligere opens links in the right browser for that particular situation based on configuration you created

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
