const Utils = require("../../modules/utils.js");
const Embed = Utils.Embed;

module.exports = {
  name: "setup",
  run: async (bot, message, args) => {
    if (message.author.id !== message.guild.ownerID)
      return message.channel.send(
        Embed({
          preset: "error",
          description: "Selle käsu käivitamiseks peate olema serveri omanik",
        })
      );

    let missing =
      await require("../../modules/methods/getMissingRolesAndChannels")(
        bot,
        message.guild
      );

    if (
      !missing.roles.length &&
      !missing.channels.text.length &&
      !missing.channels.voice.length &&
      !missing.channels.categories.length
    )
      return message.channel.send(
        Embed({
          preset: "error",
          description:
            "Teie server on juba seadistatud (pole puuduvaid rolle ega kanaleid)",
        })
      );

    message.channel.send(
      Embed({
        title:
          "Puuduvate rollide ja kanalite loomine... See võib veidi aega võtta.",
      })
    );

    let create = async () => {
      return new Promise(async (resolve) => {
        let log = `Rakenduses tehti järgmised muudatused ${message.guild.name} server:\n`;

        await missing.roles.forEach((role) => {
          log += `\nLoodud ${
            role.name
          } Roll \n> Vajalik järgmiste seadete jaoks:\n>  ${role.setting.join(
            "\n>  "
          )}\n`;
          message.guild.roles.create({ data: { name: role.name } });
        });

        await missing.channels.text.forEach((channel) => {
          log += `\nLoodud ${
            channel.name
          } Tekstikanal \n> Vajalik järgmiste seadete jaoks:\n>  ${channel.setting.join(
            "\n>  "
          )}\n`;
          message.guild.channels.create(channel.name, { type: "text" });
        });

        await missing.channels.voice.forEach((channel) => {
          log += `\nLoodud ${
            channel.name
          } Helikanal \n> Vajalik järgmiste seadete jaoks:\n>  ${channel.setting.join(
            "\n>  "
          )}\n`;
          message.guild.channels.create(channel.name, { type: "voice" });
        });

        await missing.channels.categories.forEach((channel) => {
          log += `\nLoodud ${
            channel.name
          } Kategooria \n> Vajalik järgmiste seadete jaoks:\n>  ${channel.setting.join(
            "\n>  "
          )}\n`;
          message.guild.channels.create(channel.name, { type: "category" });
        });

        resolve(log);
      });
    };

    create().then(async (log) => {
      message.channel.send(
        Embed({
          author: {
            text: "Your server is now set up for DTeam!",
            icon: "https://cdn.discordapp.com/avatars/718586276210802749/479e1e16b47b1e25a2548483e14ced64.png",
          },
          timestamp: new Date(),
          description:
            "Kõik puuduvad kanalid ja rollid on loodud. Kõikide tehtud muudatuste täielikku logi saab vaadata siit: " +
            (await Utils.paste(log)) +
            "\n\n **Ärge unustage rolle ümber järjestada, kui teil on pärimine lubatud!**",
        })
      );
    });
  },
  description: "Create any missing channels and roles for the server",
  usage: "setup",
  aliases: ["install"],
};
