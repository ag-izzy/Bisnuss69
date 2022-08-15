const Utils = require("../../modules/utils.js");
const { Embed } = Utils;
const { config, lang } = Utils.variables;

module.exports = {
  name: "debug",
  run: async (bot, message, args) => {
    const msg = await message.channel.send(
      Embed({
        title: ":tools: Creating Debug Report",
        description: "Your debug report is being generated",
      })
    );
    require("../../modules/methods/generateDebug")(bot).then((url) => {
      msg.edit(
        Embed({
          title: ":white_check_mark: Debug Raport tehtud!",
          description: "Palun saada see url Lil Dolbajoba#4276:\n" + url,
        })
      );
    });
  },
  description: "Create a DolbaTX Debug Report",
  usage: "debug",
  aliases: [],
};
