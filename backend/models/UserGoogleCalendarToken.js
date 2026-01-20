import { DataTypes } from 'sequelize'
import { sequelize } from '../sequelize.js'

// Uma linha por usuário (barbeiro) com credenciais do Google Calendar.
export const UserGoogleCalendarToken = sequelize.define(
  'UserGoogleCalendarToken',
  {
    id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
    userId: { type: DataTypes.INTEGER, allowNull: false, unique: true, field: 'user_id' },

    googleEmail: { type: DataTypes.STRING(255), allowNull: true, field: 'google_email' },
    calendarId: {
      type: DataTypes.STRING(255),
      allowNull: false,
      defaultValue: 'primary',
      field: 'calendar_id',
    },

    accessTokenEnc: { type: DataTypes.TEXT, allowNull: true, field: 'access_token_enc' },
    accessTokenIv: { type: DataTypes.STRING(64), allowNull: true, field: 'access_token_iv' },
    accessTokenTag: { type: DataTypes.STRING(64), allowNull: true, field: 'access_token_tag' },

    refreshTokenEnc: { type: DataTypes.TEXT, allowNull: true, field: 'refresh_token_enc' },
    refreshTokenIv: { type: DataTypes.STRING(64), allowNull: true, field: 'refresh_token_iv' },
    refreshTokenTag: { type: DataTypes.STRING(64), allowNull: true, field: 'refresh_token_tag' },

    // expiry_date que o googleapis usa é em ms (epoch).
    expiryDateMs: { type: DataTypes.BIGINT, allowNull: true, field: 'expiry_date_ms' },

    connectedAt: { type: DataTypes.DATE, allowNull: false, field: 'connected_at' },
    updatedAt: { type: DataTypes.DATE, allowNull: false, field: 'updated_at' },
  },
  {
    tableName: 'user_google_calendar_tokens',
    timestamps: false,
  }
)
