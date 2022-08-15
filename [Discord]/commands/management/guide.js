const Discord = require("discord.js");
const MessageEmbed = require("discord.js");

module.exports = {
  name: "guide",
  run: async (bot, message, args) => {
    const exampleEmbed = new MessageEmbed()
      .setColor("#F1C40F")
      .setTitle("Guide")
      .setURL("https://discord.js.org/")
      .setAuthor({
        name: "DTeam",
        iconURL: "https://i.imgur.com/AfFp7pu.png",
        url: "https://discord.js.org",
      })
      .setDescription("Some description here")
      .setThumbnail("https://i.imgur.com/AfFp7pu.png")
      .addFields(
        { name: "Regular field title", value: "Some value here" },
        { name: "\u200B", value: "\u200B" },
        { name: "Inline field title", value: "Some value here", inline: false },
        { name: "Inline field title", value: "Some value here", inline: false }
      )
      .addField("Inline field title", "Some value here", true)
      .setImage("https://i.imgur.com/AfFp7pu.png")
      .setTimestamp()
      .setFooter({
        text: "DTeam",
        iconURL: "https://i.imgur.com/AfFp7pu.png",
      });

    channel.send({ embeds: [exampleEmbed] });
  },
};
