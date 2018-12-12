package de.zweidenker.connectivity.list

import android.content.Context
import android.content.Intent
import android.os.Build
import android.support.annotation.RequiresApi
import android.support.v7.widget.RecyclerView
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.WindowInsets
import de.zweidenker.connectivity.R
import de.zweidenker.connectivity.config.DeviceConfigActivity
import de.zweidenker.p2p.beacon.Device
import de.zweidenker.p2p.core.IdGenerator
import kotlinx.android.synthetic.main.item_device.view.*
import java.util.LinkedList

/**
 * This Adapter displays a list of Device through a RecyclerView.
 * It contains also a header and footer item to wrap around the list for status and navigation bar.
 * The header also contains extra space for a header on the page which can be scrolled away with the list.
 */
class DeviceAdapter(context: Context) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    private val itemList = LinkedList<Device>()
    private val headerId = IdGenerator.getId()
    private val footerId = IdGenerator.getId()
    private var headerSize = 0
    private var headerBottomMargin = context.resources.getDimensionPixelSize(R.dimen.list_header_margin)
    private var footerSize = 0

    init {
        setHasStableIds(true)
    }

    override fun getItemViewType(position: Int): Int {
        return if(isVirtualPosition(position)) {
            ViewTypes.Spacer.ordinal
        } else {
            ViewTypes.Device.ordinal
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return when(viewType) {
            ViewTypes.Device.ordinal -> {
                val inflater = LayoutInflater.from(parent.context)
                val view = inflater.inflate(R.layout.item_device, parent, false)
                DeviceViewHolder(view)
            }
           else -> {
               val view = View(parent.context)
               view.layoutParams = ViewGroup.LayoutParams(1, 1)
               SpacerViewHolder(view)
            }
        }
    }

    override fun getItemId(position: Int): Long {
        return when (position) {
            0 -> headerId
            itemList.size + 1 -> footerId
            else -> itemList.get(position - 1).id
        }
    }

    override fun getItemCount(): Int {
        return itemList.size + 2
    }

    override fun onBindViewHolder(viewHolder: RecyclerView.ViewHolder, position: Int) {
        when (position) {
            0 -> (viewHolder as? SpacerViewHolder)?.bind(headerSize)
            itemList.size + 1 -> (viewHolder as? SpacerViewHolder)?.bind(footerSize)
            else -> {
                val item = itemList.get(position - 1)
                (viewHolder as? DeviceViewHolder)?.bind(item)
            }
        }
    }

    fun addItem(device: Device) {
        itemList.addLast(device)
        notifyItemInserted(itemList.size)
    }

    fun addAll(devices: Collection<Device>) {
        val startIndex = itemList.size + 1
        itemList.addAll(devices)
        notifyItemRangeInserted(startIndex, devices.size)
    }

    fun clear() {
        itemList.clear()
        notifyDataSetChanged()
    }

    @RequiresApi(Build.VERSION_CODES.KITKAT_WATCH)
    fun setInsets(insets: WindowInsets) {
        headerSize = insets.systemWindowInsetTop + headerBottomMargin
        footerSize = insets.systemWindowInsetBottom
        notifyItemChanged(0)
        notifyItemChanged(itemList.size + 1)
    }

    private fun isVirtualPosition(position: Int): Boolean {
        return position == 0 || position > itemList.size
    }

    private enum class ViewTypes {
        Device,
        Spacer
    }

    private class DeviceViewHolder(itemView: View): RecyclerView.ViewHolder(itemView) {
        private val titleTextView = itemView.card_title
        private val subtitleTextView = itemView.card_subtitle
        private val detailsTextView = itemView.card_detail

        fun bind(device: Device) {
            titleTextView.text = device.userIdentifier
            subtitleTextView.text = device.domainName
            detailsTextView.text = device.connectionStatus.name
            itemView.setOnClickListener {
                DeviceConfigActivity.startActivity(it.context, device)
                //TODO: Overwrite pending transition?
            }
        }

        fun recycle() {
            itemView.setOnClickListener(null)
        }
    }

    private class SpacerViewHolder(itemView: View): RecyclerView.ViewHolder(itemView) {

        fun bind(size: Int) {
            itemView.layoutParams = itemView.layoutParams.apply {
                height = size
            }
        }
    }
}
